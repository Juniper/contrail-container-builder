ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Init container" \
      description="Container is used to configure nodes/OS for Contrail services."

RUN yum install -y openssl && \
    yum install -y --downloadonly --downloaddir=/ contrail-tripleo-puppet && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
