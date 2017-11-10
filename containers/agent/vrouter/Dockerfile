ARG CONTRAIL_VERSION=4.0.1.0-32
ARG CONTRAIL_REGISTRY=localhost:5000
FROM ${CONTRAIL_REGISTRY}/contrail-agent-base:${CONTRAIL_VERSION}

RUN yum install -y contrail-vrouter-agent contrail-vrouter contrail-vrouter-init contrail-k8s-cni

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-agent"]

LABEL net.juniper.nodemgr.filter.name=contrail-vrouter-agent
LABEL net.juniper.contrail=agent
LABEL net.juniper.node=agent
