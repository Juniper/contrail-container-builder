ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-query-engine","--conf_file","/etc/contrail/contrail-query-engine.conf"]

LABEL net.juniper.nodemgr.filter.name=contrail-query-engine
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
