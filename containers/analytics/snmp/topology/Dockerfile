ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-snmp-base:${CONTRAIL_CONTAINER_TAG}

LABEL summary="Analytics SNMP Topology" \
	  description="Analytics SNMP Topology periodically looks at snmp info and corelate and update topology table, which is used by UI to draw maps" \
	  
ARG CONTAINER_NAME

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-topology"]

ENV SERVICE_NAME=topology
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
