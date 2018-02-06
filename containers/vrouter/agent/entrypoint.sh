#!/bin/bash

source /common.sh

HYPERVISOR_TYPE=${HYPERVISOR_TYPE:-'kvm'}
VROUTER_HOSTNAME=${VROUTER_HOSTNAME:-${DEFAULT_HOSTNAME}}

echo "INFO: agent started in $AGENT_MODE mode"
IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
pci_address=$(get_pci_address_for_nic $phys_int)
echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac, pci=$pci_address"

# For dpdk case is is expected vhost0 is down here
# but for regular case it shold be up
if is_dpdk ; then
    nic_to_read_net_parameters=$phys_int
else
    nic_to_read_net_parameters='vhost0'
fi
VROUTER_GATEWAY=${VROUTER_GATEWAY:-`get_default_gateway_for_nic $nic_to_read_net_parameters`}
vrouter_cidr=$(get_cidr_for_nic $nic_to_read_net_parameters)
echo "INFO: $nic_to_read_net_parameters cidr $vrouter_cidr, gateway $VROUTER_GATEWAY"
if [[ -z "$vrouter_cidr" ]] ; then
    echo "ERROR: $nic_to_read_net_parameters interface is down or has no assigned IP"
    exit -1
fi
vrouter_ip=${vrouter_cidr%/*}
if [[ -z "$VROUTER_GATEWAY" ]] ; then
    echo "ERROR: VROUTER_GATEWAY is empty or there is no default route for $nic_to_read_net_parameters"
    exit -1
fi

agent_mode_options="physical_interface_mac = $phys_int_mac"
if is_dpdk ; then
    read -r -d '' agent_mode_options << EOM
platform=${AGENT_MODE}
physical_interface_mac = $phys_int_mac
physical_interface_address = $pci_address
physical_uio_driver=${DPDK_UIO_DRIVER}
EOM
fi

mkdir -p -m 777 /var/crashes

echo "INFO: Preparing /etc/contrail/contrail-vrouter-agent.conf"
cat << EOM > /etc/contrail/contrail-vrouter-agent.conf
[CONTROL-NODE]
servers=${XMPP_SERVERS:-`get_server_list CONTROL ":$XMPP_SERVER_PORT "`}

[DEFAULT]
collectors=$COLLECTOR_SERVERS
log_file=${VROUTER_LOG_FILE:-"$LOG_DIR/contrail-vrouter-agent.log"}
log_level=${VROUTER_LOG_LEVEL:-$LOG_LEVEL}
log_local=${VROUTER_LOG_LOCAL:-$LOG_LOCAL}

xmpp_dns_auth_enable = $XMPP_SSL_ENABLE
xmpp_auth_enable = $XMPP_SSL_ENABLE
xmpp_server_cert=${XMPP_SERVER_CERT}
xmpp_server_key=${XMPP_SERVER_KEY}
xmpp_ca_cert=${XMPP_SERVER_CA_CERT}

$agent_mode_options

$sandesh_client_config

[NETWORKS]
control_network_ip=$vrouter_ip

[DNS]
servers=${DNS_SERVERS:-`get_server_list CONTROL ":$DNS_SERVER_PORT "`}

[METADATA]
metadata_proxy_secret=${METADATA_PROXY_SECRET}

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
echo /etc/contrail/contrail-vrouter-agent.conf
cat /etc/contrail/contrail-vrouter-agent.conf

set_vnc_api_lib_ini

function provision_node_background() {
    wait_for_contrail_api
    provision_node provision_vrouter.py $vrouter_ip $VROUTER_HOSTNAME
}

provision_node_background &

exec "$@"
