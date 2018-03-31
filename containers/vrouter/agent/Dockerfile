ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-vrouter-base:${CONTRAIL_CONTAINER_TAG}


RUN yum install -y dhclient NetworkManager contrail-vrouter-agent haproxy libvirt-client \
      python-opencontrail-vrouter-netns python-contrail-vrouter-api && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-agent"]

LABEL net.juniper.contrail.service=agent
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
