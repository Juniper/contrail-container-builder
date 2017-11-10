ARG CONTRAIL_VERSION=4.0.1.0-32
ARG CONTRAIL_REGISTRY=localhost:5000
FROM ${CONTRAIL_REGISTRY}/contrail-controller-control-base:${CONTRAIL_VERSION}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-control"]

LABEL net.juniper.nodemgr.filter.name=contrail-control
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
