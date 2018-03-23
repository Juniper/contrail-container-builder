#!/bin/bash

source /common.sh
source /agent-functions.sh

copy_agent_tools_to_host

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

if ! prepare_phys_int_dpdk ; then
  echo "FATAL: failed to initialize data for DPDK mode... exiting"
  exit -1
fi

exec $@
