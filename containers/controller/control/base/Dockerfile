ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-control contrail-dns && \
    yum clean all -y && \
    rm -rf /var/cache/yum

LABEL net.juniper.contrail.pod=control
CMD ["/usr/bin/tail","-f","/dev/null"]
