#!/bin/bash

source /common.sh
source /agent-functions.sh

if [[ -n "${DPDK_UIO_DRIVER}" && -f "/${DPDK_UIO_DRIVER}_defs" ]]; then
  source "/${DPDK_UIO_DRIVER}_defs"
fi

echo "INFO: dpdk started"

function trap_dpdk_agent_quit() {
    term_process $dpdk_agent_process
    if [ -n "$pci_address" ] ; then
        restore_phys_int_dpdk "$pci_address"
    else
        echo "WARNING: PCIs list is empty, nothing to rebind to initial net driver"
    fi
    cleanup_vrouter_agent_files
}

function trap_dpdk_agent_term() {
    term_process $dpdk_agent_process
}

# Clean up files and vhost0, when SIGQUIT signal by clean-up.sh
trap 'trap_dpdk_agent_quit' SIGQUIT

# Terminate process only.
# When a container/pod restarts it sends TERM and KILL signal.
# Every time container restarts we dont want to reset data plane
trap 'trap_dpdk_agent_term' SIGTERM SIGINT

pre_start_init

# remove rte configuration file (for case if vRouter has crashed)
rm -f '/run/.rte_config'

ensure_hugepages $HUGE_PAGES_DIR

set_ctl vm.nr_hugepages ${HUGE_PAGES}
set_ctl vm.max_map_count 128960
set_ctl net.ipv4.tcp_keepalive_time 5
set_ctl net.ipv4.tcp_keepalive_probes 5
set_ctl net.ipv4.tcp_keepalive_intvl 1
set_ctl net.core.wmem_max 9160000

for driver in $(echo $dpdk_drivers_to_load | tr ',' ' ') ; do
    load_kernel_module $driver
done

# multiple kthreads for port monitoring
if ! load_kernel_module rte_kni kthread_mode=multiple ; then
    echo "WARNING: rte_ini kernel module is unavailable. Please install/insert it for Ubuntu 14.04 manually."
fi

if ! read_and_save_dpdk_params ; then
    echo "FATAL: failed to read data from NIC for DPDK mode... exiting"
    exit -1
fi

function assert_file() {
    local file=$1
    if [[ ! -f "$file" ]] ; then
        echo "ERROR: there is no file $file"
        exit -1
    fi
}

binding_data_dir='/var/run/vrouter'
assert_file "$binding_data_dir/nic"
phys_int=`cat "$binding_data_dir/nic"`
assert_file "$binding_data_dir/${phys_int}_mac"
phys_int_mac=`cat "$binding_data_dir/${phys_int}_mac"`
assert_file "$binding_data_dir/${phys_int}_pci"
pci_address=`cat "$binding_data_dir/${phys_int}_pci"`
echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac, pci=$pci_address"
vlan_data=''
if [[ -f "$binding_data_dir/${phys_int}_vlan" ]] ; then
    vlan_data=$(cat "$binding_data_dir/${phys_int}_vlan")
    echo "INFO: vlan_data: $vlan_data"
fi
bond_data=''
if [[ -f "$binding_data_dir/${phys_int}_bond" ]] ; then
    bond_data=$(cat "$binding_data_dir/${phys_int}_bond")
    echo "INFO: bond_data: $bond_data"
fi

# base command
cmd="$@ --no-daemon $DPDK_COMMAND_ADDITIONAL_ARGS"

# update command with taskset options (core mask)
# TODO: consider to avoid taskset here and leave to manage by Docker
if [[ -n "$CPU_CORE_MASK" ]] ; then
    taskset_param="$CPU_CORE_MASK"
    if [[ "${CPU_CORE_MASK}" =~ [,-] ]]; then
        taskset_param="-c $CPU_CORE_MASK"
    fi
    cmd="/bin/taskset $taskset_param $cmd"
fi

# update command with socket mem option
dpdk_socket_mem=''
for _ in /sys/devices/system/node/node*/hugepages ; do
    if [[ -z "${dpdk_socket_mem}" ]] ; then
        dpdk_socket_mem="${DPDK_MEM_PER_SOCKET}"
    else
        dpdk_socket_mem+=",${DPDK_MEM_PER_SOCKET}"
    fi
done
[ -z "${dpdk_socket_mem}" ] && dpdk_socket_mem="${DPDK_MEM_PER_SOCKET}"
cmd+=" --socket-mem $dpdk_socket_mem"

# update command with vlan & bond options
if [[ -n "$vlan_data" ]] ; then
    vlan_id=$(echo "$vlan_data" | cut -d ' ' -f 1)
    vlan_parent=$(echo "$vlan_data" | cut -d ' ' -f 2)
    cmd+=" --vlan_tci ${vlan_id} --vlan_fwd_intf_name ${vlan_parent}"
fi
if [[ -n "$bond_data" ]] ; then
    mode=$(echo "$bond_data" | cut -d ' ' -f 1)
    policy=$(echo "$bond_data" | cut -d ' ' -f 2)
    numa=$(echo "$bond_data" | cut -d ' ' -f 5)
    # use list of slaves pci for next check of bind
    pci_address=$(echo "$bond_data" | cut -d ' ' -f 4)
    cmd+=" --vdev eth_bond_${phys_int},mode=${mode},xmit_policy=${policy},socket_id=${numa},mac=$phys_int_mac"
    for s in ${pci_address//,/ } ; do
        cmd+=",slave=${s}"
    done
    echo "INFO: bonding: removing bond interface from Linux..."
    ifdown $phys_int
    ip link del $phys_int
fi

if [ -n "$dpdk_driver_to_bind" ]; then
    if ! bind_devs_to_driver "$dpdk_driver_to_bind" "${pci_address//,/ }" ; then
        echo "FATAL: failed to bind $pci_address to the driver ${dpdk_driver_to_bind}... exiting"
        exit -1
    fi
fi

echo "INFO: start '$cmd'"
$cmd &
dpdk_agent_process=$!

export CONTRAIL_DPDK_CONTAINER_CONTEXT='true'
for i in {1..3} ; do
    echo "INFO: init vhost0... $i"
    init_vhost0 && break
    if (( i == 3 )) ; then
        echo "ERROR: failed to init vhost0.. exit"
        term_process $dpdk_agent_process
        exit -1
    fi
    sleep 3
done

wait $dpdk_agent_process
