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

xmpp_server_cert=${XMPP_SERVER_CERT}
xmpp_server_key=${XMPP_SERVER_KEY}
xmpp_ca_cert=${XMPP_SERVER_CA_CERT}

# Http server port for inspecting vnswad state (useful for debugging)
# http_server_port=${HTTP_SERVER_PORT:-8085}

# Category for logging. Default value is '*'
# log_category=$LOG_CATEGORY

# Number of tx-buffers on pkt0 interface
# pkt0_tx_buffers=${PKT0_TX_BUFFER:-1000}

# Measure delays in different queues
# measure_queue_delay=${MEASURE_QUEUE_DELAY:-0}

# agent_mode=$AGENT_MODE
# gateway_mode=$GATEWAY_MODE

# Enable/Disable local flow message logging. Possible values are 0 (disable) and 1 (enable)
# log_flow=${LOG_FLOW:-0}

[RESTART]
backup_idle_timeout=${BACKUP_IDLE_TIMEOUT:-10000}
backup_dir=${BACKUP_DIR:-"/var/lib/contrail/backup"}
backup_file_count=${BACKUP_FILE_COUNT:-3}

# Enable/Disable backup of config and resource files
backup_enable=${BACKUP_ENABLE:-false}

#huge_page_2M=$HUGE_PAGE_2M
#huge_page_1G=$HUGE_PAGE_1G
restore_enable=${RESTORE_ENABLE:-false}
restore_audit_timeout=${RESTORE_AUDIT_TIMEOUT:-15000}

#
# Directory containing backup of config and resource files
# backup_dir=/var/lib/contrail/backup
#
# Number of backup files
# backup_file_count=3
#
# Agent avoids generating backup file if change is detected within time
# configured below (in milli-sec)
# backup_idle_timeout=10000
#
# Restore config/resource definitions from file
# restore_enable=true
#
# Audit time for config/resource read from file
# restore_audit_timeout=15000
#
# Huge pages, mounted at the files specified below, to be used by vrouter
# running in kernel mode for flow table and brige table.
# huge_page_1G=<1G_huge_page_1> <1G_huge_page_2>
# huge_page_2M=<2M_huge_page_1> <2M_huge_page_2>

[NETWORKS]
control_network_ip=$(get_default_ip)

[DNS]
servers=${DNS_SERVERS:-`get_server_list DNS ":$DNS_SERVER_PORT "`}

# Client port used by vrouter-agent while connecting to contrail-named
# dns_client_port=${DNS_CLIENT_PORT}

# Timeout for DNS server queries in milli-seconds
# dns_timeout=${DNS_TIMEOUT}

# Maximum retries for DNS server queries
# dns_max_retries=${DNS_MAX_RETRIES}

[METADATA]
metadata_proxy_secret=${METADATA_PROXY_SECRET}

# Metadata proxy port on which agent listens (Optional)
# metadata_proxy_port=${METADATA_PROXY_PORT}

# Enable(true) ssl support for metadata proxy service
  metadata_use_ssl=${METADATA_USE_SSL:-TRUE}

# Path for Metadata Agent client certificate
# metadata_client_cert=${METADATA_CLIENT_CERT}

# Metadata Agent client certificate type(default=PEM)
# metdata_client_cert_type=${METADATA_CLIENT_CERT_TYPE}

# Path for Metadata Agent client private key
# metadata_client_key=${METADATA_CLIENT_KEY}

# Path for CA certificate
# metadata_ca_cert=${METADATA_CA_CERT}

[VIRTUAL-HOST-INTERFACE]
name=vhost0
ip=$vrouter_cidr
physical_interface=$phys_int
gateway=$VROUTER_GATEWAY
compute_node_address=$vrouter_ip

# Flag to indicate if hosts in vhost subnet can be resolved by ARP
# If set to 1 host in subnet would be resolved by ARP, if set to 0
# all the traffic destined to hosts within subnet also go via
# default gateway
# subnet_hosts_resolvable=${SUBNET_HOSTS_RESOLVABLE:-0}

[SERVICE-INSTANCE]
netns_command=/usr/bin/opencontrail-vrouter-netns
docker_command=/usr/bin/opencontrail-vrouter-docker

[HYPERVISOR]

# Everything in this section is optional

# Hypervisor type. Possible values are kvm, xen and vmware
type = $HYPERVISOR_TYPE

# Link-local IP address and prefix in ip/prefix_len format (for xen)
# xen_ll_ip=${XEN_LL_IP}

# Link-local interface name when hypervisor type is Xen
# xen_ll_interface=${XEN_LL_INTERFACE}

# Physical interface name when hypervisor type is vmware
# vmware_physical_interface=${VMWARE_PHYSICAL_INTERFACE}

# Mode of operation for VMWare. Possible values esxi_neutron, vcenter
# default is esxi_neutron
# vmware_mode=${VMWARE_MODE}

[FLOWS]
fabric_snat_hash_table_size = $FABRIC_SNAT_HASH_TABLE_SIZE

# Everything in this section is optional

# Number of threads for flow setup
thread_count=${THREAD_COUNT:-2}

# Maximum flows allowed per VM (given as % of maximum system flows)
# max_vm_flows=$MAX_VM_FLOWS

# Maximum number of link-local flows allowed across all VMs
# max_system_linklocal_flows=${MAX_SYSTEM_LINK_LOCAL_FLOWS:-4096}

# Maximum number of link-local flows allowed per VM
# max_vm_linklocal_flows=${MAX_VM_LINK_LOCAL_FLOWS:-1024}

# Number of Index state-machine events to log
# index_sm_log_count=${INDEX_SM_LOG_COUNT:-0}

# Enable/Disable tracing of flow messages. Introspect can over-ride this value
# trace_enable=${TRACE_ENABLE:-false}

# Number of add-tokens
# add_tokens=${ADD_TOKENS:-100}
# Number of ksync-tokens
# ksync_tokens=${KSYNC_TOKENS:-50}
# Number of del-tokens
# del_tokens=${DEL_TOKENS:-50}
# Number of update-tokens
# update_tokens=${UPDATE_TOKENS:-50}

# Maximum sessions that can be encoded in single SessionAggInfo entry. This is
# used during export of session messages. Default is 100
# max_sessions_per_aggregate=${MAX_SESSIONS_PER_AGGREGATE:-100}

# Maximum aggregate entries that can be encoded in single SessionEndpoint entry
# This is used during export of session messages. Default is 8
# max_aggregates_per_session_endpoint=${MAX_AGGREGATE_PER_SSN_ENDP:-8}

# Maximum SessionEndpoint entries that can be encoded in single
# SessionEndpointObject. This is used during export of session messages. Default
# is 5
# max_endpoints_per_session_msg=${MAX_ENDP_PER_SSN_MSG:-5}

[MAC-LEARNING]
# thread_count=${MAC_LEARN_THREAD_COUNT}
# Number of add-tokens
# add_tokens=${MAC_LEARN_ADD_TOKENS}
# Number of del-tokens
# del_tokens=${MAC_LEARN_DEL_TOKENS}
# Number of update-tokens
# update_tokens=${MAC_LEARN_UPDATE_TOKENS}

[TASK]
# Log message if time taken to execute task exceeds a threshold (in msec)
# log_exec_threshold =${LOG_EXEC_THRESHOLD:-10}
#
# Log message if time taken to schedule task exceeds a threshold (in msec)
# log_schedule_threshold =${LOG_SCHEDULE_THRESHOLD:-25}
#
# TBB Keepawake timer interval in msec
# tbb_keepawake_timeout =${TBB_KEEPAWAKE_TIMEOUT:-20}
#
# Timeout for task monitor in msec
# task_monitor_timeout =${TASK_MONITOR_TIMEOUT:-50000}
#
# Policy to pin the ksync netlink io thread to CPU. By default, CPU pinning
# is disabled. Other values for policy are,
# "last" - Last CPUID
# "<num>" - CPU-ID to pin (in decimal)
# ksync_thread_cpu_pin_policy=last

[SERVICES]
# bgp_as_a_service_port_range - reserving set of ports to be used.
# bgp_as_a_service_port_range=30000-35000
# bgp_as_a_service_port_range=${BGP_AS_A_SERVICE_PORT_RANGE}

[LLGR]
# Note: All time values are in seconds.

# End of Rib Rx(received from CN)
# Fallback time in seconds to age out stale entries on CN becoming
# active this is used only when end-of-rib is not seen from CN.
# end_of_rib_rx_fallback_time=${END_OF_RIB_RX_FALLBACK_TIME}

# End of Rib Tx(to be sent to CN)
# Fallback time in seconds to send EOR to CN. Agent waits for inactivity to
# send the same however it may so happen that activity never dies down,
# so use fallback.
# Inactivity time is the time agent waits to conclude EOC. During this interval
# no config will be seen.
# end_of_rib_tx_fallback_time=${END_OF_RIB_TX_FALLBACK_TIME}
# end_of_rib_tx_inactivity_time=${END_OF_RIB_TX_INACTIVITY_TIME}

# Config cleanup time
# Once end of config is determined this time is used to start stale cleanup
# of config.
# stale_config_cleanup_time=${STALE_CONFIG_CLEANUP_TIME}

# End of config determination time
# Inactivity time is the time agent waits to conclude EOC. During this interval
# no config will be seen.
# Fallback time in seconds to find EOC in case config inactivity is not seen.
# config_fallback_time=${CONFIG_FALLBACK_TIME}
# config_inactivity_time=${CONFIG_INACTIVITY_TIME}

EOM

add_ini_params_from_env VROUTER_AGENT /etc/contrail/contrail-vrouter-agent.conf

echo "INFO: /etc/contrail/contrail-vrouter-agent.conf"
cat /etc/contrail/contrail-vrouter-agent.conf

set_vnc_api_lib_ini

mkdir -p -m 777 /var/crashes

exec $@
