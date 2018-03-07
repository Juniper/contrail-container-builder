ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum clean all && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.nodemgr.filter.name=contrail-vcenter-plugin
LABEL net.juniper.contrail=vcenter-plugin
LABEL net.juniper.node=vcenter-plugin


