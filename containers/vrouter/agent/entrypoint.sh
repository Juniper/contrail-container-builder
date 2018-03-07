#!/bin/bash

source /common.sh
source /agent-functions.sh

HYPERVISOR_TYPE=${HYPERVISOR_TYPE:-'kvm'}

echo "INFO: agent started in $AGENT_MODE mode"

# wait vhost0
while (true) ; do
    # TODO: net-watchdog container does init for dpdk case,
    # because vhost0 is re-created each time dpdk container
    # restarted, so its initialization is needed at runtime,
    # not only at init time. here is the TODO to remove
    # that container after problem be solved at agent level.
    # For Non dpdk case jsut init vhost here,
    # because net-watchdog is not needed at all.
    if ! is_dpdk ; then
        init_vhost0
    fi
    if ! wait_nic vhost0 ; then
        sleep 20
        continue
    fi

    # TODO: avoid duplication of reading parameters with init_vhost0
    IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
    if ! is_dpdk ; then
        pci_address=$(get_pci_address_for_nic $phys_int)
    else
        binding_data_dir='/var/run/vrouter'
        pci_address=`cat $binding_data_dir/${phys_int}_pci`
    fi

    VROUTER_GATEWAY=${VROUTER_GATEWAY:-`get_default_gateway_for_nic 'vhost0'`}
    vrouter_cidr=$(get_cidr_for_nic 'vhost0')
    echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac, pci=$pci_address"
    echo "INFO: vhost0 cidr $vrouter_cidr, gateway $VROUTER_GATEWAY"

    if [[ -n "$vrouter_cidr" ]] ; then
        break
    fi
done

if [[ -z "$vrouter_cidr" ]] ; then
    echo "ERROR: vhost0 interface is down or has no assigned IP"
    exit -1
fi
vrouter_ip=${vrouter_cidr%/*}
if [[ -z "$VROUTER_GATEWAY" ]] ; then
    echo "ERROR: VROUTER_GATEWAY is empty or there is no default route for vhost0"
    exit -1
fi

agent_mode_options="physical_interface_mac = $phys_int_mac"
if is_dpdk ; then
    read -r -d '' agent_mode_options << EOM
platform=${AGENT_MODE}
physical_interface_mac=$phys_int_mac
physical_interface_address=$pci_address
physical_uio_driver=${DPDK_UIO_DRIVER}
EOM
fi

tsn_agent_mode=""
if is_tsn ; then
    TSN_AGENT_MODE="tsn-no-forwarding"
    read -r -d '' tsn_agent_mode << EOM
agent_mode = tsn-no-forwarding
EOM
fi

subcluster_option=""
if [[ -n ${SUBCLUSTER} ]]; then
  read -r -d '' subcluster_option << EOM
subcluster_name=${SUBCLUSTER}
EOM
fi

tsn_server_list=""
IFS=' ' read -ra TSN_SERVERS <<< "${TSN_NODES}"
read -r -d '' tsn_server_list << EOM
tsn_servers = ${TSN_SERVERS}
EOM

echo "INFO: Preparing /etc/contrail/contrail-vrouter-agent.conf"
cat << EOM > /etc/contrail/contrail-vrouter-agent.conf
[CONTROL-NODE]
servers=${XMPP_SERVERS:-`get_server_list CONTROL ":$XMPP_SERVER_PORT "`}
$subcluster_option

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
$tsn_agent_mode
$tsn_server_list

$sandesh_client_config

[NETWORKS]
control_network_ip=$(get_default_ip)

[DNS]
servers=${DNS_SERVERS:-`get_server_list DNS ":$DNS_SERVER_PORT "`}

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

add_ini_params_from_env VROUTER_AGENT /etc/contrail/contrail-vrouter-agent.conf

echo "INFO: /etc/contrail/contrail-vrouter-agent.conf"
cat /etc/contrail/contrail-vrouter-agent.conf

set_vnc_api_lib_ini

mkdir -p -m 777 /var/crashes

exec $@
