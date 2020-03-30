ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail VNC Configuration Schema Transformer" \
      description="Contrail Schema Transformer compiles the high level, intent based data model into a low level configuration data model."

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-schema", "--conf_file", "/etc/contrail/contrail-schema.conf", "--conf_file", "/etc/contrail/contrail-keystone-auth.conf"]

ENV SERVICE_NAME=schema
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
