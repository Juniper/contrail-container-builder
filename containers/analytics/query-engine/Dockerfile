ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Query Engine" \
      description="Contrail Query Engine handles the queries to access data from Analytics DB."

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-query-engine","--conf_file","/etc/contrail/contrail-query-engine.conf"]

ENV NODE_TYPE=database
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE

ENV SERVICE_NAME=query-engine
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
