ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-control-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-controller-control-dns" \
      summary="Controller DNS" \
      description="Controller DNS provides DNS service to the VMs spawned on different compute nodes."

ARG CONTAINER_NAME

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-dns"]

ENV SERVICE_NAME=dns
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
