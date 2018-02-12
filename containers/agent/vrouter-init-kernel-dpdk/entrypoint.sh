#!/bin/bash -x

source /common.sh

HUGE_PAGES_DIR=${HUGE_PAGES_DIR:-'/dev/hugepages'}
if [[ ! -d "$HUGE_PAGES_DIR" ]] ; then
    echo "WARNING: There is no $HUGE_PAGES_DIR mounted from host. Try to create and mount hugetlbfs."
    if ! mkdir -p $HUGE_PAGES_DIR ; then
        echo "ERROR: failed to create $HUGE_PAGES_DIR"
        exit -1
    fi
    if ! mount -t hugetlbfs hugetlbfs $HUGE_PAGES_DIR ; then
        echo "ERROR: failed to mount hugetlbfs to $HUGE_PAGES_DIR"
        exit -1
    fi
fi

if [[ ! -d "$HUGE_PAGES_DIR" ]]  ; then
    echo "ERROR: There is no $HUGE_PAGES_DIR. Probably HugeTables are anuvailable on the host."
    exit -1
fi

function set_ctl() {
    local var=$1
    local value=$2
    if grep -q "^$var" /etc/sysctl.conf ; then
        sed -i "s/^$var.*=.*/$var=$value/g"  /etc/sysctl.conf
    else
        echo "$var=$value" >> /etc/sysctl.conf
    fi
}

set_ctl vm.nr_hugepages ${HUGE_PAGES}
set_ctl vm.max_map_count 128960
set_ctl net.ipv4.tcp_keepalive_time 5
set_ctl net.ipv4.tcp_keepalive_probes 5
set_ctl net.ipv4.tcp_keepalive_intvl 1
sysctl --system

function load_kernel_module() {
    local module=$1
    shift 1
    local opts=$@
    echo "INFO: load $module kernel module"
    if ! modprobe -v "$module" $opts ; then
        echo "ERROR: failed to load $module driver"
        exit -1
    fi
}

function unload_kernel_module() {
    local module=$1
    echo "INFO: unload $module kernel module"
    if ! rmmod $module ; then
        echo "WARNING: Failed to unload $module driver"
    fi
}

load_kernel_module uio
load_kernel_module "$DPDK_UIO_DRIVER"
if ! is_ubuntu_xenial && ! is_centos; then
    # multiple kthreads for port monitoring
    # TODO: for centos if failes
    load_kernel_module rte_kni kthread_mode=multiple
fi

exec "$@"
