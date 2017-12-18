ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

COPY entrypoint.sh /

RUN echo hallo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-analytics-api","-c","/etc/contrail/contrail-analytics-api.conf","-c","/etc/contrail/contrail-keystone-auth.conf"]

LABEL net.juniper.nodemgr.filter.name=contrail-analytics-api
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
