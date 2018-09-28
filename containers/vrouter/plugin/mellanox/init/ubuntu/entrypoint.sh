#!/bin/bash

# these next folders must be mounted to install mellanox kernel drivers in ubuntu: /usr/src /lib/modules

UBUNTU_RELEASE=`lsb_release -r -s`

export DEBIAN_FRONTEND=noninteractive

cat << EOF > /etc/apt/sources.list.d/mellanox_mlnx_ofed.list
#
# Mellanox Technologies Ltd. public repository configuration file.
# For more information, refer to http://linux.mellanox.com
#
#[mlnx_ofed_latest]
deb [trusted=yes] file:/store/ubuntu${UBUNTU_RELEASE}/ ./
EOF

apt-get update
apt-get -y --reinstall --allow-unauthenticated install mlnx-ofed-dpdk-upstream-libs

exec $@
