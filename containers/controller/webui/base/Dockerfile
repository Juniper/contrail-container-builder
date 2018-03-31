ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y nodejs-0.10.35-1contrail.el7 contrail-web-controller contrail-web-core && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

LABEL net.juniper.contrail.pod=webui
CMD ["/usr/bin/tail","-f","/dev/null"]
