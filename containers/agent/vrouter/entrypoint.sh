#!/bin/bash

source /common.sh

PHYS_INT=$(get_vrouter_nic)
PHYS_INT_MAC=$(get_vrouter_mac)
if [[ -z "$PHYS_INT_MAC" ]] ; then
    echo "ERROR: failed to read MAC for NIC '${PHYS_INT}'"
    exit -1
fi
echo "INFO: Physical interface: $PHYS_INT, mac=$PHYS_INT_MAC"

# It is expected that vhost0 is up and running here
VROUTER_CIDR=$(get_cidr_for_nic vhost0)
if [[ -z "$VROUTER_CIDR" ]] ; then
    echo "ERROR: vhost0 interface is down or has no assigned IP"
    exit -1
fi

# It is expected that default gateway is known here
VROUTER_GATEWAY=${VROUTER_GATEWAY:-`get_default_gateway_for_nic vhost0`}
if [[ -z "$VROUTER_GATEWAY" ]] ; then
    echo "ERROR: VROUTER_GATEWAY is empty or there is no default route for vhost0"
    exit -1
fi

echo "INFO: vhost0 cidr $VROUTER_CIDR, gateway $VROUTER_GATEWAY"

HYPERVISOR_TYPE="${HYPERVISOR_TYPE:-kvm}"
mkdir -p -m 777 /var/crashes

# Prepare agent configs
echo "INFO: Preparing /etc/contrail/contrail-vrouter-agent.conf"
cat << EOM > /etc/contrail/contrail-vrouter-agent.conf
[CONTROL-NODE]
servers=${XMPP_SERVERS:-`get_server_list CONTROL ":$XMPP_SERVER_PORT "`}

[DEFAULT]
collectors=$COLLECTOR_SERVERS
log_file=${VROUTER_LOG_FILE:-"$LOG_DIR/contrail-vrouter-agent.log"}
log_level=${VROUTER_LOG_LEVEL:-$LOG_LEVEL}
log_local=${VROUTER_LOG_LOCAL:-$LOG_LOCAL}

xmpp_dns_auth_enable = False
xmpp_auth_enable = False
physical_interface_mac = $PHYS_INT_MAC

[SANDESH]
introspect_ssl_enable = False
sandesh_ssl_enable = False

[DNS]
servers=${DNS_SERVERS:-`get_server_list CONTROL ":$DNS_SERVER_PORT "`}

[METADATA]
metadata_proxy_secret=contrail

[VIRTUAL-HOST-INTERFACE]
name=vhost0
ip=$VROUTER_CIDR
physical_interface=$PHYS_INT
gateway=$VROUTER_GATEWAY

[SERVICE-INSTANCE]
netns_command=/usr/bin/opencontrail-vrouter-netns
docker_command=/usr/bin/opencontrail-vrouter-docker

[HYPERVISOR]
type = $HYPERVISOR_TYPE
EOM

set_vnc_api_lib_ini

# Prepare default_pmac
echo $PHYS_INT_MAC > /etc/contrail/default_pmac

wait_for_contrail_api

vrouter_ip=${VROUTER_CIDR%/*}
vrouter_name=${VROUTER_HOSTNAME:-${DEFAULT_HOSTNAME}}
provision_node provision_vrouter.py $vrouter_ip $vrouter_name

exec "$@"
