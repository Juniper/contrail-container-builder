ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-vrouter-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

RUN yum install -y dhclient NetworkManager contrail-vrouter-dpdk contrail-vrouter-dpdk-init && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY entrypoint.sh /
COPY *_defs /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-dpdk"]

ENV SERVICE_NAME=agent-dpdk
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
