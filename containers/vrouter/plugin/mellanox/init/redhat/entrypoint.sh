#!/bin/bash -e

# /lib/modules needs to be mounted.

yum --nogpgcheck -y install mlnx-ofed-dpdk-upstream-libs

exec $@
