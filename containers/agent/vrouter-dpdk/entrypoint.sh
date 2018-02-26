#!/bin/bash

source /common.sh

echo "INFO: agent started in $AGENT_MODE mode"

function assert_file() {
    local file=$1
    if [[ ! -f "$file" ]] ; then
        echo "ERROR: there is no file $file"
        exit -1
    fi
}

phys_int=`get_default_physical_iface`
binding_data_dir='/var/run/vrouter'
assert_file "$binding_data_dir/${phys_int}_mac"
phys_int_mac=`cat "$binding_data_dir/${phys_int}_mac"`
assert_file "$binding_data_dir/${phys_int}_pci"
pci_address=`cat "$binding_data_dir/${phys_int}_pci"`
echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac, pci=$pci_address"

# ensure device is bind to dpdk driver
wait_device_for_driver $DPDK_UIO_DRIVER $pci_address

# TODO: consider to avoid taskset here and leave to manage by Docker
cmd="$@"
real_cmd=$cmd
if [[ -n "$CPU_CORE_MASK" ]] ; then
    taskset_param="$CPU_CORE_MASK"
    if [[ "${CPU_CORE_MASK}" =~ [,-] ]]; then
        taskset_param="-c $CPU_CORE_MASK"
    fi
    real_cmd="/bin/taskset $taskset_param $cmd"
fi

mkdir -p -m 777 /var/crashes
ensure_log_dir /var/log/contrail

# remove rte configuration file (for case if vRouter has crashed)
# TODO: most probably not needed.. since crash means container re-created
rm -f '/run/.rte_config'

# set maximum socket buffer size to (max hold flows entries * 9160 bytes)
set_ctl net.core.wmem_max 9160000

echo "INFO: exec '$real_cmd'"
exec $real_cmd
