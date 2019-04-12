ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-webui-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-controller-webui-web" \
      summary="Controller WEB UI" \
      description="Controller WEB UI provides the WebUI service to end user."

ARG CONTAINER_NAME

ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /usr/src/contrail/contrail-web-core
CMD ["/usr/bin/node","webServerStart.js"]

ENV SERVICE_NAME=web
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
