#!/bin/bash

source /common.sh

HYPERVISOR_TYPE=${HYPERVISOR_TYPE:-'kvm'}
VROUTER_HOSTNAME=${VROUTER_HOSTNAME:-${DEFAULT_HOSTNAME}}
VROUTER_GATEWAY=${VROUTER_GATEWAY:-`get_default_gateway_for_nic vhost0`}

phys_int=$(get_vrouter_nic)
phys_int_mac=$(get_vrouter_mac)
if [[ -z "$phys_int_mac" ]] ; then
    echo "ERROR: failed to read MAC for NIC '${phys_int}'"
    exit -1
fi
echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac"

# It is expected that vhost0 is up and running here
vrouter_cidr=$(get_cidr_for_nic vhost0)
if [[ -z "$vrouter_cidr" ]] ; then
    echo "ERROR: vhost0 interface is down or has no assigned IP"
    exit -1
fi
vrouter_ip=${vrouter_cidr%/*}

# It is expected that default gateway is known here
if [[ -z "$VROUTER_GATEWAY" ]] ; then
    echo "ERROR: VROUTER_GATEWAY is empty or there is no default route for vhost0"
    exit -1
fi

echo "INFO: vhost0 cidr $vrouter_cidr, gateway $VROUTER_GATEWAY"

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
physical_interface_mac = $phys_int_mac

[SANDESH]
introspect_ssl_enable = False
sandesh_ssl_enable = False

[NETWORKS]
control_network_ip=$vrouter_ip

[DNS]
servers=${DNS_SERVERS:-`get_server_list CONTROL ":$DNS_SERVER_PORT "`}

[METADATA]
metadata_proxy_secret=contrail

[VIRTUAL-HOST-INTERFACE]
name=vhost0
ip=$vrouter_cidr
physical_interface=$phys_int
gateway=$VROUTER_GATEWAY
compute_node_address=$vrouter_ip

[SERVICE-INSTANCE]
netns_command=/usr/bin/opencontrail-vrouter-netns
docker_command=/usr/bin/opencontrail-vrouter-docker

[HYPERVISOR]
type = $HYPERVISOR_TYPE
EOM

set_vnc_api_lib_ini

# Prepare default_pmac
echo $phys_int_mac > /etc/contrail/default_pmac

wait_for_contrail_api

provision_node provision_vrouter.py $vrouter_ip $VROUTER_HOSTNAME

exec "$@"
