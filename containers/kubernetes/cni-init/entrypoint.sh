#!/bin/bash

source /common.sh

VROUTER_PORT=${VROUTER_PORT:-9091}
KUBEMANAGER_NESTED_MODE=${KUBEMANAGER_NESTED_MODE:-'0'}
MESOS_IP=${MESOS_IP:-'localhost'}
MESOS_PORT=${MESOS_PORT:-6991}
CLUSTER_NAME=${CLUSTER_NAME:-'mesos'}
run_command="$@"

trap cleanup SIGHUP SIGINT SIGTERM

ulimit -s unlimited
ulimit -c unlimited
ulimit -d unlimited
ulimit -v unlimited
ulimit -n 4096

if [ $CLOUD_ORCHESTRATOR == 'mesosphere' ]; then
# In Mesos Environment
mkdir -p /host/log_cni
mkdir -p /host/mesos_etc_dcos_network/cni
mkdir -p /host/opt_mesos_active_cni
mkdir -p /var/lib/contrail/ports/vm

cp /usr/bin/contrail-k8s-cni /host/opt_mesos_active_cni/contrail-cni-plugin
chmod 0755 /host/opt_mesos_active_cni/contrail-cni-plugin

tar -C /host/opt_mesos_active_cni -xzf /opt/cni-v0.3.0.tgz

# Prepare config for Mesos CNI plugin
# Note: Uses 127.0.0.1 as VROUTER_IP because it is always run on
# the node with vrouter agent
cat << EOM > /host/mesos_etc_dcos_network/cni/contrail-cni-plugin.conf
{
    "cniVersion": "0.3.1",
    "contrail" : {
        "vrouter-ip"    : "127.0.0.1",
        "vrouter-port"  : $VROUTER_PORT,
        "cluster-name"  : $CLUSTER_NAME,
        "config-dir"    : "/var/lib/contrail/ports/vm",
        "poll-timeout"  : 5,
        "poll-retries"  : 15,
        "log-file"      : "/var/log/contrail/cni/opencontrail.log",
        "log-level"     : "debug",
        "mesos-ip"      : $MESOS_IP,
        "mesos-port"    : $MESOS_PORT,
        "mode"          : "mesos"
    },

    "name": "contrail-mesos-cni",
    "type": "contrail-mesos-cni"
}
EOM

else
# In Kubernetes environment
mkdir -p /host/log_cni
mkdir -p /host/etc_cni/net.d
mkdir -p /host/opt_cni_bin
mkdir -p /var/lib/contrail/ports/vm

cp /usr/bin/contrail-k8s-cni /host/opt_cni_bin
chmod 0755 /host/opt_cni_bin/contrail-k8s-cni

tar -C /host/opt_cni_bin -xzf /opt/cni-v0.3.0.tgz

if [ $KUBEMANAGER_NESTED_MODE == '0' ]; then

# Not executing in nested mode. Populate CNI config accordingly.

# Prepare config for CNI plugin
# Note: Uses 127.0.0.1 as VROUTER_IP because it is always run on
# the node with vrouter agent
cat << EOM > /host/etc_cni/net.d/10-contrail.conf
{
    "cniVersion": "0.3.1",
    "contrail" : {
        "vrouter-ip"    : "127.0.0.1",
        "vrouter-port"  : $VROUTER_PORT,
        "config-dir"    : "/var/lib/contrail/ports/vm",
        "poll-timeout"  : 5,
        "poll-retries"  : 15,
        "log-file"      : "/var/log/contrail/cni/opencontrail.log",
        "log-level"     : "4"
    },

    "name": "contrail-k8s-cni",
    "type": "contrail-k8s-cni"
}
EOM

else

# Executing in nested mode. Populate CNI config accordingly.

phys_int=$(get_vrouter_physical_iface)
cat << EOM > /host/etc_cni/net.d/10-contrail.conf
{
   "cniVersion": "0.3.1",
   "contrail" : {
       "mode"              : "k8s",
       "vif-type"          : "macvlan",
       "parent-interface"  : "$phys_int",
       "vrouter-ip"        : "$KUBERNESTES_NESTED_VROUTER_VIP",
       "vrouter-port"      : $VROUTER_PORT,
       "config-dir"        : "/var/lib/contrail/ports/vm",
       "poll-timeout"      : 5,
       "poll-retries"      : 15,
       "log-dir"          : "/var/log/contrail/cni",
       "log-file"          : "/var/log/contrail/cni/opencontrail.log",
       "log-level"         : "4"
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

exec $run_command
