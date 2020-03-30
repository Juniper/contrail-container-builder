ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-vrouter-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail DPDK poll mode driver" \
      description="DPDK support for Contrail vrouter agent"

# contrail-vrouter-dpdk-init contains dpdk_nic_bind.py that is used by this container.

RUN yum install -y dhclient NetworkManager contrail-vrouter-dpdk contrail-vrouter-dpdk-init && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY entrypoint.sh /
COPY *_defs /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-dpdk"]

ENV SERVICE_NAME=agent-dpdk
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
