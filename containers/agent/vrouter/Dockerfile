ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

RUN yum install -y contrail-vrouter-agent && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY 10-core-pattern.conf /etc/sysctl.d/
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-agent"]

LABEL net.juniper.nodemgr.filter.name=contrail-vrouter-agent
LABEL net.juniper.contrail=agent
LABEL net.juniper.node=agent
