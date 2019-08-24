ARG CONTRAIL_BASE_REGISTRY
ARG CONTRAIL_BASE_CONTAINER_TAG
FROM ${CONTRAIL_BASE_REGISTRY}/contrail-general-base:${CONTRAIL_BASE_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Mellanox plugin for RedHat" \
      description="DPDK Mellanox kernel module for RedHat."

# this copy should be before yum install
COPY *.repo /etc/yum.repos.d/

RUN yum update -y && \
    yum install --downloadonly -y mlnx-ofed-dpdk-upstream-libs && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
