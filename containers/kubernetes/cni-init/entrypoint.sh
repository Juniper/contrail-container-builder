#!/bin/bash

source /common.sh

VROUTER_PORT=${VROUTER_PORT:-9091}
KUBEMANAGER_NESTED_MODE=${KUBEMANAGER_NESTED_MODE:-'0'}
MESOS_IP=${MESOS_IP:-'localhost'}
MESOS_PORT=${MESOS_PORT:-6991}
CLUSTER_NAME=${CLUSTER_NAME:-'mesos'}
run_command="$@"
temp_fname="/host/temp_cni.conf"
file_name="/host/etc_cni/net.d/10-contrail.conf"

trap cleanup SIGHUP SIGINT SIGTERM

ulimit -s unlimited
ulimit -c unlimited
ulimit -d unlimited
ulimit -v unlimited
ulimit -n 4096

mkdir -p /host/log_cni
mkdir -p /var/lib/contrail/ports/vm

cat << EOM > $temp_fname
{
    "cniVersion": "0.3.1",
    "contrail" : {
        "config-dir"    : "/var/lib/contrail/ports/vm",
        "poll-timeout"  : 5,
        "poll-retries"  : 15,
        "log-dir"       : "/var/log/contrail/cni",
        "log-file"      : "/var/log/contrail/cni/opencontrail.log",
        "log-level"     : "4",
EOM

if [ $CLOUD_ORCHESTRATOR == 'mesos' ]; then
  # In Mesos Environment
  mkdir -p /host/opt_mesos_etc_dcos_network/cni
  mkdir -p /host/opt_mesos_active_cni

  cp /usr/bin/contrail-k8s-cni /host/opt_mesos_active_cni/contrail-cni-plugin
  chmod 0755 /host/opt_mesos_active_cni/contrail-cni-plugin

  tar -C /host/opt_mesos_active_cni -xzf /opt/cni-v0.3.0.tgz

  file_name = "/host/opt_mesos_etc_dcos_network/cni/contrail-cni-plugin.conf"
  # Prepare config for Mesos CNI plugin
  # Note: Uses 127.0.0.1 as VROUTER_IP because it is always run on
  # the node with vrouter agent
  cat << EOM >> $temp_fname
          "vrouter-port"  : $VROUTER_PORT,
          "vrouter-ip"    : "127.0.0.1",
          "mode"          : "mesos",
          "cluster-name"  : $CLUSTER_NAME,
          "mesos-ip"      : $MESOS_IP,
          "mesos-port"    : $MESOS_PORT
      },

      "name": "contrail-cni-plugin",
      "type": "contrail-cni-plugin"
  }
EOM

else
  # In Kubernetes environment
  mkdir -p /host/etc_cni/net.d
  mkdir -p /host/opt_cni_bin

  cp /usr/bin/contrail-k8s-cni /host/opt_cni_bin
  chmod 0755 /host/opt_cni_bin/contrail-k8s-cni

  tar -C /host/opt_cni_bin -xzf /opt/cni-v0.3.0.tgz

  if [ $KUBEMANAGER_NESTED_MODE == '0' ]; then
    # Not executing in nested mode. Populate CNI config accordingly.

    # Prepare config for CNI plugin
    # Note: Uses 127.0.0.1 as VROUTER_IP because it is always run on
    # the node with vrouter agent
    cat << EOM >> $temp_fname
            "vrouter-port"  : $VROUTER_PORT,
            "vrouter-ip"    : "127.0.0.1"
        },

        "name": "contrail-k8s-cni",
        "type": "contrail-k8s-cni"
    }
EOM

  else
    # Executing in nested mode. Populate CNI config accordingly.
    phys_int=$(get_vrouter_physical_iface)
    cat << EOM >> $temp_fname
           "vrouter-port"  : $VROUTER_PORT,
           "vrouter-ip"    : "$KUBERNESTES_NESTED_VROUTER_VIP",
           "mode"          : "k8s",
           "vif-type"      : "macvlan",
           "parent-interface"  : "$phys_int",
       },

       "name": "contrail-k8s-cni",
       "type": "contrail-k8s-cni"
    }
EOM

    # In nested mode, the CNI init container cannot die, as it is deployed
    # as K8s daemon set. So just loop forever to not let the pod die.
    # This can be reworked once K8s supports "run once" daemonset scheme.
    run_command="tail -f /dev/null"
  fi
fi

cat $temp_fname > $file_name
rm -rf $temp_fname

exec $run_command
