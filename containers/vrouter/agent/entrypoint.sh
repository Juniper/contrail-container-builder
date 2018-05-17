#!/bin/bash

source /common.sh
source /agent-functions.sh

echo "INFO: agent started in $AGENT_MODE mode"

# Clean up files and vhost0, when SIGQUIT signal by clean-up.sh
trap 'term_vrouter_agent $vrouter_agent_process; remove_vhost0' SIGQUIT

# Clean up files only, when a container/pod restarts it sends TERM and KILL signal
# Every time container restarts we dont want to reset data plane
trap 'term_vrouter_agent $vrouter_agent_process' SIGTERM SIGINT

# Send SIGHUP signal to child process
trap 'send_sighup_child_process $vrouter_agent_process' SIGHUP

pre_start_init

if [ "$CLOUD_ORCHESTRATOR" == "vcenter" ]; then
    HYPERVISOR_TYPE=${HYPERVISOR_TYPE:-'vmware'}
    vmware_phys_int=$(get_vmware_physical_iface)
    read -r -d '' vmware_options << EOM || true
vmware_physical_interface = $vmware_phys_int
vmware_mode = vcenter
EOM
else
    HYPERVISOR_TYPE=${HYPERVISOR_TYPE:-'kvm'}
fi

init_vhost0
if is_encryption_supported; then
   init_crypt0 $VROUTER_CRYPT_INTERFACE
   init_decrypt0 $VROUTER_DECRYPT_INTERFACE $VROUTER_DECRYPT_KEY
else
  echo "INFO: Kernel version does not support the driver required for vrouter to vrouter encryption"
fi

init_sriov

# TODO: avoid duplication of reading parameters with init_vhost0
if ! is_dpdk ; then
    IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
    pci_address=$(get_pci_address_for_nic $phys_int)
else
    binding_data_dir='/var/run/vrouter'
    phys_int=`cat $binding_data_dir/nic`
    phys_int_mac=`cat $binding_data_dir/${phys_int}_mac`
    pci_address=`cat $binding_data_dir/${phys_int}_pci`
fi

VROUTER_GATEWAY=${VROUTER_GATEWAY:-`get_default_gateway_for_nic 'vhost0'`}
vrouter_cidr=$(get_cidr_for_nic 'vhost0')
echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac, pci=$pci_address"
echo "INFO: vhost0 cidr $vrouter_cidr, gateway $VROUTER_GATEWAY"

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
    read -r -d '' agent_mode_options << EOM || true
platform=${AGENT_MODE}
physical_interface_mac=$phys_int_mac
physical_interface_address=$pci_address
physical_uio_driver=${DPDK_UIO_DRIVER}
EOM
fi

tsn_agent_mode=""
if is_tsn ; then
    TSN_AGENT_MODE="tsn-no-forwarding"
    read -r -d '' tsn_agent_mode << EOM || true
agent_mode = tsn-no-forwarding
EOM
fi

subcluster_option=""
if [[ -n ${SUBCLUSTER} ]]; then
  read -r -d '' subcluster_option << EOM || true
subcluster_name=${SUBCLUSTER}
EOM
fi

tsn_server_list=""
IFS=' ' read -ra TSN_SERVERS <<< "${TSN_NODES}"
read -r -d '' tsn_server_list << EOM || true
tsn_servers = ${TSN_SERVERS}
EOM

priority_group_option=""
if [[ -n "${PRIORITY_ID}" ]] && ! is_dpdk; then
    priority_group_option="[QOS-NIANTIC]"
    IFS=',' read -ra priority_id_list <<< "${PRIORITY_ID}"
    IFS=',' read -ra priority_bandwidth_list <<< "${PRIORITY_BANDWIDTH}"
    IFS=',' read -ra priority_scheduling_list <<< "${PRIORITY_SCHEDULING}"
    for index in ${!priority_id_list[@]}; do
        read -r -d '' qos_niantic << EOM
[PG-${priority_id_list[${index}]}]
scheduling=${priority_scheduling_list[${index}]}
bandwidth=${priority_bandwidth_list[${index}]}

EOM
        priority_group_option+=$'\n'"${qos_niantic}"
    done
    if is_vlan $phys_int; then
        echo "ERROR: qos scheduling not supported for vlan interface skipping ."
        priority_group_option=""
    fi
fi

qos_queueing_option=""
if [[ -n "${QOS_QUEUE_ID}" ]] && ! is_dpdk; then
    qos_queueing_option="[QOS]"$'\n'"priority_tagging=${PRIORITY_TAGGING}"
    IFS=',' read -ra qos_queue_id <<< "${QOS_QUEUE_ID}"
    IFS=';' read -ra qos_logical_queue <<< "${QOS_LOGICAL_QUEUES}"
    for index in ${!qos_queue_id[@]}; do
        if [[ ${index} -ge $((${#qos_queue_id[@]} - 1)) ]]; then
            break
        fi
        read -r -d '' qos_config << EOM
[QUEUE-${qos_queue_id[${index}]}]
logical_queue=${qos_logical_queue[${index}]}

EOM
        qos_queueing_option+=$'\n'"${qos_config}"
    done
    qos_def=""
    if is_enabled ${QOS_DEF_HW_QUEUE} ; then
        qos_def="default_hw_queue=true"
    fi

    if [[ ${#qos_queue_id[@]} -ne ${#qos_logical_queue[@]} ]]; then
        qos_logical_queue+=('[]')
    fi

    read -r -d '' qos_config << EOM
[QUEUE-${qos_queue_id[-1]}]
logical_queue=${qos_logical_queue[-1]}
${qos_def}

EOM
    qos_queueing_option+=$'\n'"${qos_config}"
fi

metadata_ssl_conf=''
if is_enabled "$METADATA_SSL_ENABLE" ; then
    read -r -d '' metadata_ssl_conf << EOM
metadata_use_ssl=${METADATA_SSL_ENABLE}
metadata_client_cert=${METADATA_SSL_CERTFILE}
metadata_client_key=${METADATA_SSL_KEYFILE}
metadata_ca_cert=${METADATA_SSL_CA_CERTFILE}
EOM
    if [[ -n "$METADATA_SSL_CERT_TYPE" ]] ; then
        metadata_ssl_conf+=$'\n'"${METADATA_SSL_CERT_TYPE}"
    fi
fi

crypt_intf_setup=""
if is_encryption_supported; then
read -r -d '' crypt_intf_setup << EOM || true
[CRYPT]
crypt_interface=$VROUTER_CRYPT_INTERFACE
EOM
fi

echo "INFO: Preparing /etc/contrail/contrail-vrouter-agent.conf"
cat << EOM > /etc/contrail/contrail-vrouter-agent.conf
[CONTROL-NODE]
servers=${XMPP_SERVERS:-`get_server_list CONTROL ":$XMPP_SERVER_PORT "`}
$subcluster_option

[DEFAULT]
collectors=$COLLECTOR_SERVERS
log_file=$LOG_DIR/contrail-vrouter-agent.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL

xmpp_dns_auth_enable=${XMPP_SSL_ENABLE}
xmpp_auth_enable=${XMPP_SSL_ENABLE}
$xmpp_certs_config

$agent_mode_options
$tsn_agent_mode
$tsn_server_list

$sandesh_client_config

[NETWORKS]
control_network_ip=$(get_ip_for_vrouter_from_control)

[DNS]
servers=${DNS_SERVERS:-`get_server_list DNS ":$DNS_SERVER_PORT "`}

[METADATA]
metadata_proxy_secret=${METADATA_PROXY_SECRET}
$metadata_ssl_conf

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
$vmware_options

[FLOWS]
fabric_snat_hash_table_size = $FABRIC_SNAT_HASH_TABLE_SIZE

$qos_queueing_option

$priority_group_option

$crypt_intf_setup

EOM

cleanup_lbaas_netns_config

add_ini_params_from_env VROUTER_AGENT /etc/contrail/contrail-vrouter-agent.conf

if [[ -n "${PRIORITY_ID}" ]] || [[ -n "${QOS_QUEUE_ID}" ]]; then
    if is_dpdk ; then
       echo "INFO: Qos provisioning not supported for dpdk vrouter. Skipping."
    else
        interface_list="${phys_int}"
        if is_bonding ${phys_int} ; then
            IFS=' ' read -r mode policy slaves pci_addresses bond_numa <<< $(get_bonding_parameters $phys_int)
            interface_list="${slaves}"
        fi
        python /opt/contrail/utils/qosmap.py --interface_list ${interface_list}
    fi
fi

echo "INFO: /etc/contrail/contrail-vrouter-agent.conf"
cat /etc/contrail/contrail-vrouter-agent.conf

set_vnc_api_lib_ini
create_lbaas_auth_conf

# spin up vrouter-agent as a child process
"$@" &
vrouter_agent_process=$!

# This is to ensure decrypt interface is
# plumbed on vrouter for processing.
# it will be interim only till vrouter
# agent natively have the support for
# decrypt interface in 5.0.1
if is_encryption_supported; then
   add_vrouter_decrypt_intf $VROUTER_DECRYPT_INTERFACE
else
   echo "INFO: Kernel version does not support vrouter to vrouter encryption - Not adding $VROUTER_DECRYPT_INTERFACE to vrouter"
fi

# Wait for vrouter-agent process to complete
wait $vrouter_agent_process
