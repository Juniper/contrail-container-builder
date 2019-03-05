ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

# contrail-config-openstack contains svc_monitor and vnc_openstack modules
RUN sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf && \
    yum install --cacheonly -y contrail-config contrail-config-openstack

ENV NODE_TYPE=config
LABEL net.juniper.contrail.pod=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
