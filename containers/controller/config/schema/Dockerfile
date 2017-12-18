ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-schema","--conf_file","/etc/contrail/contrail-schema.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]

LABEL net.juniper.nodemgr.filter.name=contrail-schema
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
