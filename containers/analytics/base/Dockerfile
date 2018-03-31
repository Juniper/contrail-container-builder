ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-analytics python-sqlalchemy && \
    yum clean all -y && \
    rm -rf /var/cache/yum

LABEL net.juniper.contrail.pod=analytics
CMD ["/usr/bin/tail","-f","/dev/null"]
