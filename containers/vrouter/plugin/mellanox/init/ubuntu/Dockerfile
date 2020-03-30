ARG UBUNTU_DISTR=ubuntu
ARG UBUNTU_DISTR_VERSION=18.04
FROM $UBUNTU_DISTR:$UBUNTU_DISTR_VERSION
ARG VENDOR_NAME
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="mellanox vrouter kernel module for ubuntu" \
      description="This image is used to build vrouter.ko for current ubuntu OS that it's running on."

# Add required license as text file in Liceses directory
RUN mkdir /licenses
COPY __licensing.txt /licenses/licensing.txt

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

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
