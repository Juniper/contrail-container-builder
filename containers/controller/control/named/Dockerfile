ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
FROM ${CONTRAIL_REGISTRY}/contrail-controller-control-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-named","-f","-g","-u","contrail","-c","/etc/contrail/dns/contrail-named.conf"]

LABEL net.juniper.nodemgr.filter.name=contrail-named
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
