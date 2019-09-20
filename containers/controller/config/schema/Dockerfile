ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail VNC Configuration Schema Transformer" \
      description="Contrail Schema Transformer compiles the high level, intent based data model into a low level configuration data model."
ARG CONTRAIL_BUILD_FROM_SOURCE

# contrail-config-openstack contains svc_monitor and vnc_openstack modules
RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]]; then \
    sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf && \
    yum clean all -y && \
    rm -rf /var/cache/yum; \
    fi

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-schema", "--conf_file", "/etc/contrail/contrail-schema.conf", "--conf_file", "/etc/contrail/contrail-keystone-auth.conf"]

ENV SERVICE_NAME=schema
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME

