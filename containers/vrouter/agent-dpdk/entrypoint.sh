#!/bin/bash

source /common.sh
source /agent-functions.sh

pre_start_init

echo "INFO: dpdk started"
# remove rte configuration file (for case if vRouter has crashed)
# TODO: most probably not needed.. since crash means container re-created
rm -f '/run/.rte_config'

ensure_hugepages $HUGE_PAGES_DIR

set_ctl vm.nr_hugepages ${HUGE_PAGES}
set_ctl vm.max_map_count 128960
set_ctl net.ipv4.tcp_keepalive_time 5
set_ctl net.ipv4.tcp_keepalive_probes 5
set_ctl net.ipv4.tcp_keepalive_intvl 1
set_ctl net.core.wmem_max 9160000

load_kernel_module uio
load_kernel_module "$DPDK_UIO_DRIVER"
# multiple kthreads for port monitoring
if ! load_kernel_module rte_kni kthread_mode=multiple ; then
  echo "WARNING: rte_ini kernel module is unavailable. Please install/insert it for Ubuntu 14.04 manually."
fi

if ! prepare_phys_int_dpdk ; then
  echo "FATAL: failed to initialize data for DPDK mode... exiting"
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
cmd="$@ --no-daemon"

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
fi

# ensure devices are bind to dpdk driver
for pci in ${pci_address//,/ } ; do
    wait_device_for_driver $DPDK_UIO_DRIVER $pci
done

echo "INFO: exec '$cmd'"
exec $cmd
