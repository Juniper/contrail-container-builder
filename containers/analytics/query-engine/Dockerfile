ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-newton
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-query-engine","--conf_file","/etc/contrail/contrail-query-engine.conf"]

LABEL net.juniper.nodemgr.filter.name=contrail-query-engine
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
