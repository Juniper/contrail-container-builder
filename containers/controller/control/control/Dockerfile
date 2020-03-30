ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-control-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Controller" \
      description="Contrail Control is xmpp/bgp based routing engine for Contrail."

COPY entrypoint.sh /

# cap_net_bind_service for bgp port 179
RUN setcap cap_net_bind_service+ep /usr/bin/contrail-control

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-control"]

ENV SERVICE_NAME=control
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
