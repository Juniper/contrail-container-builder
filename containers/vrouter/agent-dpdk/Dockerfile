ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-vrouter-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

RUN yum install -y wget numactl-libs libnl3 perl && \
    (wget -nv http://content.mellanox.com/ofed/MLNX_OFED-4.3-1.0.1.0/MLNX_OFED_LINUX-4.3-1.0.1.0-rhel7.4-x86_64.tgz || \
    wget -nv https://github.com/Juniper/contrail-thirdparty-cache-large/releases/download/1.0/MLNX_OFED_LINUX-4.3-1.0.1.0-rhel7.4-x86_64.tgz) && \
    mkdir /mlnx_ofed && \
    tar -zxf MLNX_OFED_LINUX-4.3-1.0.1.0-rhel7.4-x86_64.tgz --strip-components 2 -C /mlnx_ofed && \
    /mlnx_ofed/mlnxofedinstall -q --dpdk --user-space-only && \
    rm -rf MLNX_OFED_LINUX-4.3-1.0.1.0-rhel7.4-x86_64.tgz mlnx_ofed

RUN yum install -y contrail-vrouter-dpdk contrail-vrouter-dpdk-init && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-dpdk"]

LABEL net.juniper.contrail.service=agent-dpdk
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
