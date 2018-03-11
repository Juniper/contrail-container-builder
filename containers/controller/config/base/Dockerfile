ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

# contrail-config-openstack contains svc_monitor and vnc_openstack modules
RUN yum install -y contrail-config contrail-config-openstack && \
    yum clean all -y && \
    rm -rf /var/cache/yum

LABEL net.juniper.contrail.pod=config
CMD ["/usr/bin/tail","-f","/dev/null"]
