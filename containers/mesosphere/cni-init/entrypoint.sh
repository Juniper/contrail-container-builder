#!/bin/bash

source /common.sh

VROUTER_IP=${VROUTER_IP:-$(get_ip_for_vrouter_from_control)}
VROUTER_PORT=${VROUTER_PORT:-9091}

MESOS_IP=${MESOS_IP:-$DEFAULT_LOCAL_IP}
MESOS_PORT=${MESOS_PORT:-6991}
CLUSTER_NAME=${CLUSTER_NAME:-'mesos'}

trap cleanup SIGHUP SIGINT SIGTERM

ulimit -s unlimited
ulimit -c unlimited
ulimit -d unlimited
ulimit -v unlimited
ulimit -n 4096

mkdir -p /host/log_cni
mkdir -p /var/lib/contrail/ports/vm
mkdir -p /host/opt_mesos_etc_dcos_network/cni
mkdir -p /host/opt_mesos_active_cni

cp /usr/bin/contrail-mesos-cni /host/opt_mesos_active_cni/contrail-cni-plugin
chmod 0755 /host/opt_mesos_active_cni/contrail-cni-plugin

tar -C /host/opt_mesos_active_cni -xzf /opt/cni-v0.3.0.tgz

# Prepare config for Mesos CNI plugin
cat << EOM > /host/opt_mesos_etc_dcos_network/cni/contrail-cni-plugin.conf
{
    "cniVersion": "0.3.1",
    "contrail" : {
        "config-dir"    : "/var/lib/contrail/ports/vm",
        "poll-timeout"  : 5,
        "poll-retries"  : 15,
        "log-dir"       : "$LOG_FOLDER_ABS_PATH/cni",
        "log-file"      : "$LOG_FOLDER_ABS_PATH/cni/opencontrail.log",
        "log-level"     : "4",
        "vrouter-port"  : $VROUTER_PORT,
        "vrouter-ip"    : "$VROUTER_IP",
        "mode"          : "mesos",
        "cluster-name"  : "$CLUSTER_NAME",
        "mesos-ip"      : "$MESOS_IP",
        "mesos-port"    : "$MESOS_PORT"
    },

    "name": "contrail-cni-plugin",
    "type": "contrail-cni-plugin"
}
EOM
