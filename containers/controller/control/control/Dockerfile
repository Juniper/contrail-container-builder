ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-control-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-controller-control-control" \
      summary="Controller Control" \
      description="Controller Control accepts XMPP connections from vrouter nodes."

ARG CONTAINER_NAME

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-control"]

ENV SERVICE_NAME=control
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
