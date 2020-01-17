ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ENV VENDOR_DOMAIN=$VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Provisioner" \
      description="Contrail Provisioner ia caoneiner that manage env for other containers."

COPY *.sh /
ENTRYPOINT ["/entrypoint.sh"]

ENV SERVICE_NAME=provisioner
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME

CMD ["/usr/bin/tail","-f","/dev/null"]