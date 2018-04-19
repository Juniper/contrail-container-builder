ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

# contrail-config-openstack contains svc_monitor and vnc_openstack modules
RUN sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf && \
    yum install -y contrail-config contrail-config-openstack

LABEL net.juniper.contrail.pod=config
CMD ["/usr/bin/tail","-f","/dev/null"]
