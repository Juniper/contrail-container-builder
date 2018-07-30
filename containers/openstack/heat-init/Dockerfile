ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

RUN yum install -y contrail-heat && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
