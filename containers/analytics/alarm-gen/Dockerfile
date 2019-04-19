ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Alarm Generator" \
      description="Contrail Alarm Generator generates alerts (alarms) which highlight unusual conditions that may require more urgent administrator attention and action."

# TODO: split contrail-analytics package to several small packages and use contrail-base then
# FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-alarm-gen","-c","/etc/contrail/contrail-alarm-gen.conf"]

ENV NODE_TYPE=analytics-alarm
LABEL net.juniper.contrail.pod=$NODE_TYPE

ENV SERVICE_NAME=alarm-gen
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
