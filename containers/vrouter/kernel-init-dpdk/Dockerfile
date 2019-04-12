ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-vrouter-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-vrouter-kernel-init-dpdk" \
      summary="DPDK vRouter" \
      description="vRouter runs as a user space process and uses DPDK for fast path Packet I/O."

ARG CONTAINER_NAME

RUN yum install -y contrail-vrouter-dpdk-init && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
