#!/bin/bash

apt-get update
apt-get -y install lsb-release apt-utils dpkg-dev

export DEBIAN_FRONTEND=noninteractive

for UBUNTU_RELEASE in 16.04
do
cat << EOF > /etc/apt/sources.list.d/mellanox_mlnx_ofed.list
#
# Mellanox Technologies Ltd. public repository configuration file.
# For more information, refer to http://linux.mellanox.com
#
#[mlnx_ofed_latest]
deb [trusted=yes] http://linux.mellanox.com/public/repo/mlnx_ofed_dpdk_upstream_libs/latest-contrail/ubuntu${UBUNTU_RELEASE}/\$(ARCH) ./
EOF

apt-get update
mkdir -p /store/ubuntu${UBUNTU_RELEASE}
cd /store/ubuntu${UBUNTU_RELEASE}
chown -R _apt:root /store/ubuntu${UBUNTU_RELEASE}

apt-get --allow-unauthenticated download mlnx-ofed-dpdk-upstream-libs
apt-get --allow-unauthenticated download `dpkg -I /store/ubuntu${UBUNTU_RELEASE}/mlnx-ofed-dpdk-upstream-libs* | for i in $(awk -F', ' '/Depends: /{gsub(/: /, ", "); for (i=2; i<=NF; i++) { gsub(/ .*$/, "", $(i)); printf("%s\n", $(i)); } }'); do echo $i; done | tr '\n' ' '`

dpkg-scanpackages . /dev/null |  gzip -9c > Packages.gz

/bin/rm -f /etc/apt/sources.list.d/mellanox_mlnx_ofed.list
done

apt-get -y install dkms file libexpat1 libffi6 libmagic1 libpci3
apt-get -y install libpython2.7-stdlib libsqlite3-0 libssl1.0.0 libxml2
apt-get -y install libpython-stdlib libpython2.7 libpython2.7-minimal
apt-get -y install lsof mime-support pciutils python
apt-get -y install python-libxml2 python-minimal python2.7 python2.7-minimal
apt-get -y install sgml-base xml-core
apt-get -y install libicu55
