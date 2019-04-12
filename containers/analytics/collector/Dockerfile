ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-analytics-collector" \
      summary="Analytics collector" \
      description="The data sources can be configured with the IP address of a destination collector, or there can be a load balancer for the collectors."

ARG CONTAINER_NAME

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-collector"]

ENV SERVICE_NAME=collector
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
