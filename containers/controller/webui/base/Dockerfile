ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y nodejs-0.10.35-1contrail.el7 contrail-web-controller contrail-web-core && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY custom-images/logo.png /opt/contrail/images/logo.png
COPY custom-images/favicon.ico /opt/contrail/images/favicon.ico
COPY entrypoint.sh /

ENV NODE_TYPE=webui
LABEL net.juniper.contrail.pod=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
