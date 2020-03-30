ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME

LABEL name=$CONTAINER_NAME \
      summary="Contrail SNMP Topology" \
      description="Contrail SNMP Topology periodically updates topology table, which is used by UI to draw maps."

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-topology"]

ENV SERVICE_NAME=topology
ENV NODE_TYPE=analytics-snmp
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
