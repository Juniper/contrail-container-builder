ARG CONTRAIL_BASE_REGISTRY
ARG CONTRAIL_BASE_CONTAINER_TAG
FROM ${CONTRAIL_BASE_REGISTRY}/contrail-base:${CONTRAIL_BASE_CONTAINER_TAG}
ARG VENDOR_DOMAIN

RUN yum install -y contrail-control contrail-dns && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENV NODE_TYPE=control
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
