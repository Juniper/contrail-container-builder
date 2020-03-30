ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-control-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail DNS" \
      description="Contrail DNS provides DNS service to the VMs spawned on compute nodes."

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-dns"]

ENV SERVICE_NAME=dns
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
