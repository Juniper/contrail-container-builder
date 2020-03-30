ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Service Monitor" \
      description="Contrail Service Monitor brings up and monitors any service instance that are spawned."

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-svc-monitor", "--conf_file", "/etc/contrail/contrail-svc-monitor.conf", "--conf_file", "/etc/contrail/contrail-keystone-auth.conf"]

ENV SERVICE_NAME=svc-monitor
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME