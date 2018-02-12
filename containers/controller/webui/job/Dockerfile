ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-newton
FROM ${CONTRAIL_REGISTRY}/contrail-controller-webui-base:${CONTRAIL_CONTAINER_TAG}

ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /usr/src/contrail/contrail-web-core
CMD ["/usr/bin/node","jobServerStart.js"]

LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
