ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-control-base:${CONTRAIL_CONTAINER_TAG}
ARG PROJECT_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Named" \
      description="Contrail Named complements Contrail DNS service."

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-named","-f","-g","-u","contrail","-c","/etc/contrail/dns/contrail-named.conf"]

ENV SERVICE_NAME=named
LABEL $PROJECT_DOMAIN".service"=$SERVICE_NAME
LABEL $PROJECT_DOMAIN".container.name"=$CONTAINER_NAME
