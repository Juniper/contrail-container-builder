#!/bin/bash

source /common.sh

HYPERVISOR_TYPE="${HYPERVISOR_TYPE:-kvm}"
PHYS_INT=${PHYSICAL_INTERFACE:-`get_default_nic`}
CUR_INT=$PHYS_INT
if [[ `ip address show vhost0 |grep "inet "` ]]; then
  CUR_INT=vhost0
fi
VROUTER_CIDR=`ip address show ${CUR_INT} |grep "inet "|awk '{print $2}'`
VROUTER_IP=${VROUTER_CIDR%/*}
VROUTER_MASK=${VROUTER_CIDR#*/}

if [[ `ip address show ${CUR_INT} |grep "inet "` ]]; then
  VROUTER_GATEWAY=''
  if [[ `ip route show |grep default|grep ${CUR_INT}` ]]; then
        VROUTER_GATEWAY=`ip route show |grep default|grep ${CUR_INT}|awk '{print $3}'`
  fi
fi

VROUTER_HOSTNAME=${VROUTER_HOSTNAME:-`hostname`}
PHYS_INT_MAC=$(cat /sys/class/net/${PHYS_INT}/address)

read -r -d '' contrail_vrouter_agent_config << EOM
[CONTROL-NODE]
servers=${XMPP_SERVERS:-`get_server_list CONTROLLER ":$XMPP_SERVER_PORT "`}

[DEFAULT]
collectors=$COLLECTOR_SERVERS
log_file=/var/log/contrail/contrail-vrouter-agent.log
log_level=SYS_NOTICE
log_local=1

xmpp_dns_auth_enable = False
xmpp_auth_enable = False
physical_interface_mac = $PHYS_INT_MAC

[SANDESH]
introspect_ssl_enable = False
sandesh_ssl_enable = False

[DNS]
servers=${DNS_SERVERS:-`get_server_list CONTROLLER ":$DNS_SERVER_PORT "`}

[METADATA]
metadata_proxy_secret=contrail

[VIRTUAL-HOST-INTERFACE]
name=vhost0
ip=$VROUTER_IP/$VROUTER_MASK
physical_interface=$PHYS_INT
gateway=$VROUTER_GATEWAY

[SERVICE-INSTANCE]
netns_command=/usr/bin/opencontrail-vrouter-netns
docker_command=/usr/bin/opencontrail-vrouter-docker

[HYPERVISOR]
type = $HYPERVISOR_TYPE
EOM

# VRouter specific code starts here

function pkt_setup () {
    for f in /sys/class/net/$1/queues/rx-*
    do
        q="$(echo $f | cut -d '-' -f2)"
        r=$(($q%32))
        s=$(($q/32))
        ((mask=1<<$r))
        str=(`printf "%x" $mask`)
        if [ $s -gt 0 ]; then
            for ((i=0; i < $s; i++))
            do
                str+=,00000000
            done
        fi
        echo $str > $f/rps_cpus
    done
    ip link set dev $1 up
}

function insert_vrouter() {
    if [ -f /sys/class/net/pkt1/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt1
    fi
    if [ -f /sys/class/net/pkt2/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt2
    fi
    if [ -f /sys/class/net/pkt3/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt3
    fi
    vif --create vhost0 --mac $PHYS_INT_MAC
    vif --add ${PHYS_INT} --mac $PHYS_INT_MAC --vrf 0 --vhost-phys --type physical
    vif --add vhost0 --mac $PHYS_INT_MAC --vrf 0 --type vhost --xconnect ${PHYS_INT}
    ip link set vhost0 up
    return 0
}

# Load kernel module
kver=`uname -r | awk -F"-" '{print $1}'`
modfile=`ls -1rt /opt/contrail/vrouter-kernel-modules/$kver-*/vrouter.ko | tail -1`
echo "Modprobing vrouter "$modfile
insmod $modfile
if [[ -z `lsmod | grep vrouter` ]]; then
  echo "Failed to insert vrouter kernel module"
  exit 1
fi

if [[ $CUR_INT != "vhost0" ]]; then
        echo "Inserting vrouter"
        insert_vrouter

        echo "Changing physical interface to vhost in ip table"
        ip address delete $VROUTER_IP/$VROUTER_MASK dev ${PHYS_INT}
        ip address add $VROUTER_IP/$VROUTER_MASK dev vhost0
        if [[ $VROUTER_GATEWAY ]]; then
            ip route add default via $VROUTER_GATEWAY
        fi
fi

# Prepare agent configs
echo "Preparing configs"
echo "$contrail_vrouter_agent_config" > /etc/contrail/contrail-vrouter-agent.conf
set_vnc_api_lib_ini

# Prepare default_pmac
echo $PHYS_INT_MAC > /etc/contrail/default_pmac

# Provision vrouter
echo "Provisioning vrouter"
/usr/share/contrail-utils/provision_vrouter.py  --api_server_ip $CONTROLLER_NODES --host_name $VROUTER_HOSTNAME --host_ip $VROUTER_IP --oper add

exec "$@"
