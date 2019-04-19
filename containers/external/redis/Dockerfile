FROM redis:4.0.2 

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor="Juniper" \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.0" \
      name=$CONTAINER_NAME \
      summary="Contrail Redis" \
      description="Contrail Redis server supports query engine."

COPY *.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]

ENV SERVICE_NAME=redis
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
