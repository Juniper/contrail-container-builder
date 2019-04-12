ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-analytics-query-engine" \
      summary="Analytics Query" \
      description="Analytics Query interacts with Analytics API Server via Redis and with Analytics Db"

ARG CONTAINER_NAME

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-query-engine","--conf_file","/etc/contrail/contrail-query-engine.conf"]

ENV NODE_TYPE=database
LABEL net.juniper.contrail.pod=$NODE_TYPE

ENV SERVICE_NAME=query-engine
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
