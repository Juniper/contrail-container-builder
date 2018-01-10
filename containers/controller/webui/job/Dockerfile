ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
ARG LINUX_DISTR=centos
FROM ${CONTRAIL_REGISTRY}/contrail-controller-webui-base:${CONTRAIL_VERSION}-${LINUX_DISTR}-${OPENSTACK_VERSION}

ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /usr/src/contrail/contrail-web-core
CMD ["/usr/bin/node","jobServerStart.js"]

LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
