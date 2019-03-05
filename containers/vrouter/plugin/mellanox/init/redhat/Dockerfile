ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

# this copy should be before yum install
COPY *.repo /etc/yum.repos.d/

RUN yum makecache && \
    yum install --cacheonly --downloadonly -y mlnx-ofed-dpdk-upstream-libs

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
