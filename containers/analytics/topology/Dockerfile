ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-newton
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-topology"]

LABEL net.juniper.nodemgr.filter.name=contrail-topology
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
