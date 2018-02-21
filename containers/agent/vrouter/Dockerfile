ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-agent-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-vrouter-agent haproxy \
      python-opencontrail-vrouter-netns python-contrail-vrouter-api && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-agent"]

LABEL net.juniper.nodemgr.filter.name=contrail-vrouter-agent
LABEL net.juniper.contrail=agent
LABEL net.juniper.node=agent
