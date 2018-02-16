#!/bin/bash

source /common.sh

HUGE_PAGES_DIR=${HUGE_PAGES_DIR:-'/dev/hugepages'}
ensure_hugepages $HUGE_PAGES_DIR

set_ctl vm.nr_hugepages ${HUGE_PAGES}
set_ctl vm.max_map_count 128960
set_ctl net.ipv4.tcp_keepalive_time 5
set_ctl net.ipv4.tcp_keepalive_probes 5
set_ctl net.ipv4.tcp_keepalive_intvl 1

load_kernel_module uio
load_kernel_module "$DPDK_UIO_DRIVER"
# multiple kthreads for port monitoring
if ! load_kernel_module rte_kni kthread_mode=multiple ; then
  echo "WARNING: rte_ini kernel module is unavailable. Please install/insert it for Ubuntu 14.04 manually."
fi

echo "INFO: agent $AGENT_MODE mode"
IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
pci_address=$(get_pci_address_for_nic $phys_int)
default_gw_metric=`get_default_gateway_for_nic_metric $phys_int`
echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac, pci=$pci_address"

# save data for next usage in network init container
# TODO: check that data valid for the case if container is re-run again by some reason
addrs=$(get_ips_for_nic $phys_int)
gateway=${VROUTER_GATEWAY:-"$default_gw_metric"}
binding_data_dir='/var/run/vrouter'
mkdir -p $binding_data_dir
echo "INFO: addrs=[$addrs], gateway=$gateway"
echo "$phys_int" > $binding_data_dir/${phys_int}_nic
echo "$phys_int_mac" > $binding_data_dir/${phys_int}_mac
echo "$pci_address" > $binding_data_dir/${phys_int}_pci
echo "$addrs" > $binding_data_dir/${phys_int}_ip_addresses
echo "$gateway" > $binding_data_dir/${phys_int}_gateway

if [[ "$phys_int" == "vhost0" ]] ; then
    echo "ERROR: it is not expected the vhost0 is up and running"
    exit -1
fi

# bind iface to dpdk uio driver before start dpdk agent
bind_devs_to_driver $DPDK_UIO_DRIVER $phys_int

exec $@
