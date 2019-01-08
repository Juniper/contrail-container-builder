#!/bin/bash

apt-get update
apt-get -y install lsb-core apt-utils

UBUNTU_RELEASE=`lsb_release -r -s`

export DEBIAN_FRONTEND=noninteractive

cat << EOF > /etc/apt/sources.list.d/mellanox_mlnx_ofed.list
#
# Mellanox Technologies Ltd. public repository configuration file.
# For more information, refer to http://linux.mellanox.com
#
#[mlnx_ofed_latest]
deb [trusted=yes] http://linux.mellanox.com/public/repo/mlnx_ofed_dpdk_upstream_libs/latest-contrail/ubuntu${UBUNTU_RELEASE}/\$(ARCH) ./
EOF

apt-get update
mkdir /store && cd /store && touch /store/Release
apt-get --allow-unauthenticated download mlnx-ofed-dpdk-upstream-libs
apt-get -y install dkms dpkg-dev file libexpat1 libffi6 libmagic1 libpci3
apt-get -y install libpython2.7-stdlib libsqlite3-0 libssl1.0.0 libxml2
apt-get -y install libpython-stdlib libpython2.7 libpython2.7-minimal
apt-get -y install linux-headers-generic lsof mime-support pciutils python
apt-get -y install python-libxml2 python-minimal python2.7 python2.7-minimal
apt-get -y install sgml-base xml-core

kver=`uname -r | sed -e "s/-generic//"`
apt-get -y install linux-headers-${kver} linux-headers-${kver}-generic

case "$UBUNTU_RELEASE" in
	16.04)
	apt-get -y install libicu55
	;;
	18.04)
	apt-get -y install libicu60
	;;
esac

dpkg-scanpackages . /dev/null |  gzip -9c > Packages.gz
