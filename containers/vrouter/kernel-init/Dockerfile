ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-vrouter-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Kernel init container for vrouter" \
      description="Prepares the host operating system for the contrail vrouter kernel interface."

RUN rpm -Uvh --nodeps $(repoquery --location contrail-vrouter) && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
