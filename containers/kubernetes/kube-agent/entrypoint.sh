#!/bin/bash

source /common.sh

# TODO: Rework determining vrouter ip. Should commonize it with agent's container
PHYS_INT=${PHYSICAL_INTERFACE:-`get_default_nic`}
CUR_INT=$PHYS_INT
if [[ `ip address show vhost0 |grep "inet "` ]]; then
  CUR_INT=vhost0
fi
VROUTER_CIDR=`ip address show ${CUR_INT} |grep "inet "|awk '{print $2}'`
cur_ip=${VROUTER_CIDR%/*}
VROUTER_IP=${VROUTER_IP:-$cur_ip}
VROUTER_PORT=${VROUTER_PORT:-9091}

trap cleanup SIGHUP SIGINT SIGTERM

ulimit -s unlimited
ulimit -c unlimited
ulimit -d unlimited
ulimit -v unlimited
ulimit -n 4096

mkdir -p /host/log_cni
mkdir -p /host/etc_cni/net.d
mkdir -p /host/opt_cni_bin
mkdir -p /var/lib/contrail/ports/vm

cp /usr/bin/contrail-k8s-cni /host/opt_cni_bin
chmod 0755 /host/opt_cni_bin/contrail-k8s-cni

read -r -d '' contrail_cni_conf << EOM
{
    "cniVersion": "0.2.0",
    "contrail" : {
        "vrouter-ip"    : "$VROUTER_IP",
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

echo "$contrail_cni_conf" > /host/etc_cni/net.d/10-contrail.conf
exec "$@"
