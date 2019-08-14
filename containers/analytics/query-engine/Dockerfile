ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}
ARG PROJECT_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Query Engine" \
      description="Contrail Query Engine handles the queries to access data from Analytics DB."

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-query-engine","--conf_file","/etc/contrail/contrail-query-engine.conf"]

ENV NODE_TYPE=database
LABEL $PROJECT_DOMAIN".pod"=$NODE_TYPE

ENV SERVICE_NAME=query-engine
LABEL $PROJECT_DOMAIN".service"=$SERVICE_NAME
LABEL $PROJECT_DOMAIN".container.name"=$CONTAINER_NAME
