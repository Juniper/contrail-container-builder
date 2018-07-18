#!/bin/bash

# these next folders must be mounted to install mellanox kernel drivers in ubuntu: /usr/src /lib/modules

apt-get -y --reinstall --allow-unauthenticated install mlnx-ofed-kernel-dkms

exec $@
