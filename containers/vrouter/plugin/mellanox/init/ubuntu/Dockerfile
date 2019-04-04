ARG UBUNTU_DISTR=ubuntu
ARG UBUNTU_DISTR_VERSION=16.04
FROM $UBUNTU_DISTR:$UBUNTU_DISTR_VERSION

ARG CONTAINER_NAME

# This image is used to build vrouter.ko for current ubuntu OS that it's running on.
# This container uses rpm packages to obtain source of vrouter kernel driver.
# The container needs /usr/src and /lib/modules mounted from the host to build driver.
# And we need to move out /usr/src all that packages can install there.

COPY mlnx_prepare.sh /
RUN /./mlnx_prepare.sh

COPY local_store.list /etc/apt/sources.list.d/

RUN apt-get clean

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
