ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-control contrail-dns && \
    yum clean all -y && \
    rm -rf /var/cache/yum

LABEL net.juniper.contrail.pod=control
CMD ["/usr/bin/tail","-f","/dev/null"]
