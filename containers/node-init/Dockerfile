ARG CONTRAIL_BASE_REGISTRY
ARG CONTRAIL_BASE_CONTAINER_TAG
FROM ${CONTRAIL_BASE_REGISTRY}/contrail-base:${CONTRAIL_BASE_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Init container" \
      description="Container is used to configure operating system for Contrail services."

RUN yum install -y openssl && \
    yum install -y --downloadonly --downloaddir=/ contrail-tripleo-puppet && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
