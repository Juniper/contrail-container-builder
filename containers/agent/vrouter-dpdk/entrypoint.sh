#!/bin/bash

source /common.sh

echo "INFO: agent started in $AGENT_MODE mode"
IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
pci_address=$(get_pci_address_for_nic $phys_int)
echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac, pci=$pci_address"

VROUTER_GATEWAY=${VROUTER_GATEWAY:-`get_default_gateway_for_nic $phys_int`}
vrouter_cidr=$(get_cidr_for_nic $phys_int)
echo "INFO: $phys_int cidr $vrouter_cidr, gateway $VROUTER_GATEWAY"

# TODO: consider to avoid taskset here and leave to manage by Docker
cmd="$@"
real_cmd=$cmd
if [[ -n "$CPU_CORE_MASK" ]] ; then
    taskset_param="$CPU_CORE_MASK"
    if [[ "${CPU_CORE_MASK}" =~ '[,-]' ]]; then
        taskset_param="-c $CPU_CORE_MASK"
    fi
    if is_ubuntu ; then
        real_cmd="/usr/bin/taskset $taskset_param $cmd"
    else
        real_cmd="/bin/taskset $taskset_param $cmd"
    fi
fi

mkdir -p -m 777 /var/crashes

# remove rte configuration file (for case if vRouter has crashed)
# TODO: most probably not needed.. since crash means container re-created
rm -f '/run/.rte_config'

# set maximum socket buffer size to (max hold flows entries * 9160 bytes)
sysctl -w net.core.wmem_max=9160000

# bind iface to dpdk uio driver before start dpdk agent
bind_dev_to_driver $DPDK_UIO_DRIVER $phys_int

function background_init() {
    wait_dpdk_agent_start
    if [[ -n $cmd ]] ; then
        local pname=`echo $cmd | cut -d ' ' -f 1`
        enable_hugepages_to_coredump "$pname"
    fi
    create_vhost0_dpdk $phys_int $phys_int_mac $vrouter_cidr $VROUTER_GATEWAY
}

# TODO: tart backgound job to enable hugepase to coredump
# and initialize vhost0
background_init &

echo "INFO: exec '$real_cmd'"
exec $real_cmd
