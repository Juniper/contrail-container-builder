ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME

LABEL name=$CONTAINER_NAME \
      summary="Contrail SNMP Collector" \
      description="Contrail SNMP Collector collects data from switches(Spine/Leaf)."

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-snmp-collector", "--device-config-file", "/etc/contrail/device.ini"]

ENV SERVICE_NAME=snmp-collector
ENV NODE_TYPE=analytics-snmp
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
