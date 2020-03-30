ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Alarm Generator" \
      description="Contrail Alarm Generator generates alerts (alarms) which highlight unusual conditions that may require more urgent administrator attention and action."

# TODO: split contrail-analytics package to several small packages and use contrail-base then
# FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-alarm-gen", "-c", "/etc/contrail/contrail-alarm-gen.conf"]

ENV NODE_TYPE=analytics-alarm
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE

ENV SERVICE_NAME=alarm-gen
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
