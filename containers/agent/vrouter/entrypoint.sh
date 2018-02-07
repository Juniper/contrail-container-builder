#!/bin/bash

source /common.sh

HYPERVISOR_TYPE=${HYPERVISOR_TYPE:-'kvm'}
VROUTER_HOSTNAME=${VROUTER_HOSTNAME:-${DEFAULT_HOSTNAME}}
pci_address=${pci_address:-''}

# Remove it , this is in common.sh
PHYSICAL_INTERFACE=${PHYSICAL_INTERFACE:-'bond0'}
VROUTER_GATEWAY=${VROUTER_GATEWAY:-'10.204.217.254'}

if [[ "$AGENT_PLATFORM" == 'dpdk' ]] ; then
    echo "Agent running on dpdk platform "
    phys_int=${PHYSICAL_INTERFACE}
    phys_int_mac="$(get_iface_mac $PHYSICAL_INTERFACE)"
    vrouter_cidr="$(get_cidr_for_nic $PHYSICAL_INTERFACE)"
    pci_address="$(get_pci_address_of_interface $PHYSICAL_INTERFACE)"
else
    IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
    echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac"

    # It is expected that vhost0 is up and running here
    VROUTER_GATEWAY=${VROUTER_GATEWAY:-`get_default_gateway_for_nic vhost0`}
    vrouter_cidr=$(get_cidr_for_nic vhost0)
    echo "INFO: vhost0 cidr $vrouter_cidr, gateway $VROUTER_GATEWAY"

    # It is expected that vhost0 is up and running here
    if [[ -z "$vrouter_cidr" ]] ; then
        echo "ERROR: vhost0 interface is down or has no assigned IP"
        exit -1
    fi

    if [[ -z "$VROUTER_GATEWAY" ]] ; then
        echo "ERROR: VROUTER_GATEWAY is empty or there is no default route for vhost0"
        exit -1
    fi
fi

vrouter_ip=${vrouter_cidr%/*}
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
physical_interface_address= $pci_address
platform=${AGENT_PLATFORM}

[SANDESH]
introspect_ssl_enable = False
sandesh_ssl_enable = False

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

set_vnc_api_lib_ini

# Prepare default_pmac
echo $phys_int_mac > /etc/contrail/default_pmac

# Remove dpdk service file
rm -rf /lib/systemd/system/contrail-vrouter-dpdk.service

#wait_for_contrail_api

#provision_node provision_vrouter.py $vrouter_ip $VROUTER_HOSTNAME

exec "$@"
