#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y install --no-install-recommends apt-utils dpkg-dev


for UBUNTU_RELEASE in 18.04
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

# to avoid dependency on python3.6 from dkms
apt-get -y install --no-install-recommends dkms \
    file libexpat1 libffi6 libmagic1 libpci3 \
    libpython2.7-stdlib libsqlite3-0 libssl1.0.0 libxml2 \
    libpython-stdlib libpython2.7 libpython2.7-minimal \
    lsof mime-support pciutils python \
    python-libxml2 python-minimal python2.7 python2.7-minimal \
    sgml-base xml-core libicu60
