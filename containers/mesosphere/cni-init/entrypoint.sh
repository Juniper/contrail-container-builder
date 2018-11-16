#!/bin/bash

source /common.sh

VROUTER_PORT=${VROUTER_PORT:-9091}
MESOS_IP=${MESOS_IP:-'localhost'}
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

tar -C /host/opt_cni_bin -xzf /opt/cni-v0.3.0.tgz

cat << EOM > /host/opt_mesos_etc_dcos_network/cni/contrail-cni-plugin.conf
{
    "cniVersion": "0.3.1",
    "contrail" : {
        "config-dir"    : "/var/lib/contrail/ports/vm",
        "poll-timeout"  : 5,
        "poll-retries"  : 15,
        "log-dir"       : "/var/log/contrail/cni",
        "log-file"      : "/var/log/contrail/cni/opencontrail.log",
        "log-level"     : "4",
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

exec "$@"
