#!/bin/bash

# these next folders must be mounted to install mellanox kernel drivers in ubuntu: /usr/src /lib/modules

export DEBIAN_FRONTEND=noninteractive

ubuntu_folder=$(ls -1t /store/ | head -n 1)

cat << EOF > /etc/apt/sources.list.d/mellanox_mlnx_ofed.list
#
# Mellanox Technologies Ltd. public repository configuration file.
# For more information, refer to http://linux.mellanox.com
#
#[mlnx_ofed_latest]
deb [trusted=yes] file:/store/${ubuntu_folder}/ ./
EOF

apt-get update
apt-get -y --reinstall --allow-unauthenticated install mlnx-ofed-dpdk-upstream-libs

exec $@
