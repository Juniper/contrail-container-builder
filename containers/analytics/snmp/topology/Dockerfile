ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail SNMP Topology" \
      description="Contrail SNMP Topology periodically updates topology table, which is used by UI to draw maps."

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-topology"]

ENV SERVICE_NAME=topology
ENV NODE_TYPE=analytics-snmp
LABEL net.juniper.contrail.pod=$NODE_TYPE
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
