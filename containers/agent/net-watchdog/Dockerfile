ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-agent-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y dhclient NetworkManager && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY entrypoint.sh /
COPY ifup-vhost /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.nodemgr.filter.name=contrail-vrouter-network-init
LABEL net.juniper.contrail=agent
LABEL net.juniper.node=agent
