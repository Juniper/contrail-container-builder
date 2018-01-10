ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
ARG LINUX_DISTR=centos
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_VERSION}-${LINUX_DISTR}-${OPENSTACK_VERSION}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-collector"]

LABEL net.juniper.nodemgr.filter.name=contrail-collector
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
