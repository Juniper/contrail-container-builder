ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-snmp-base:${CONTRAIL_CONTAINER_TAG}

LABEL summary="Analytics SNMP Collector" \
	  description="Analytics SNMP Collector collects data from switches(Spine/Leaf) and passes to Analytics Collector." \
	  
ARG CONTAINER_NAME

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-snmp-collector","--device-config-file","/etc/contrail/device.ini"]

ENV SERVICE_NAME=snmp-collector

LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
