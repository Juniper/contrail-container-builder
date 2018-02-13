ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y \
        ethtool pciutils sysvinit-tools \
        contrail-vrouter-utils contrail-vrouter-dpdk-init && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail=vrouter-init-kernel
LABEL net.juniper.node=agent
