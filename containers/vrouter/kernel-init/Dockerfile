ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-vrouter-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-vrouter-kernel-init" \
      summary="kernel vrouter" \
      description="The normal operation where forwarding plane of vRouter runs in the kernel and is connected to VMs."

ARG CONTAINER_NAME

RUN rpm -Uvh --nodeps $(repoquery --location contrail-vrouter) && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
