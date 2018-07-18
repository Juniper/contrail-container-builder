FROM ubuntu:16.04

ARG CONTAINER_NAME

# This image is used to build vrouter.ko for current ubuntu OS that it's running on.
# This container uses rpm packages to obtain source of vrouter kernel driver.
# The container needs /usr/src and /lib/modules mounted from the host to build driver.
# And we need to move out /usr/src all that packages can install there.

# this copy should be before apt-get install
COPY mellanox_mlnx_ofed.list /etc/apt/sources.list.d/

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    mkdir /store && cd /store && \
    apt-get --allow-unauthenticated download mlnx-ofed-kernel-dkms && \
    apt-get --allow-unauthenticated download mlnx-ofed-kernel-utils && \
    apt-get -y install dkms && \
    apt-get -y install dpkg-dev && \
    apt-get -y install file libexpat1 libffi6 libicu55 libmagic1 libpci3 && \
    apt-get -y install libpython-stdlib libpython2.7 libpython2.7-minimal && \
    apt-get -y install libpython2.7-stdlib libsqlite3-0 libssl1.0.0 libxml2 && \
    apt-get -y install lsof mime-support pciutils python && \
    apt-get -y install python-libxml2 python-minimal python2.7 python2.7-minimal && \
    apt-get -y install sgml-base xml-core && \
    dpkg-scanpackages . /dev/null |  gzip -9c > Packages.gz

COPY local_store.list /etc/apt/sources.list.d/

RUN apt-get update && apt-get clean

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
