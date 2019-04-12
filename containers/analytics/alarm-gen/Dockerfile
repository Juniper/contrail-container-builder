ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-analytics-alarm-gen" \
      summary="Analytics Alarm Gen" \
      description="Responsibility for alarm generation is distributed across nodes, \n\
                  so the Alarm Generation function subscribes to the Kafka buses in Analyticsdb nodes in order to observe the data needed to calculate \n\
                  if an alarm condition is met, since this data may be collected by other nodes."

# TODO: split contrail-analytics package to several small packages and use contrail-base then
# FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-alarm-gen","-c","/etc/contrail/contrail-alarm-gen.conf"]

ENV NODE_TYPE=analytics-alarm
LABEL net.juniper.contrail.pod=$NODE_TYPE

ENV SERVICE_NAME=alarm-gen
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
