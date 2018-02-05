ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
RUN yum install -y ironic-notification-manager && \
    yum clean all -y && \
    rm -rf /var/cache/yum
CMD ["/usr/bin/python","/usr/bin/ironic-notification-manager","--conf_file","/etc/contrail/ironic-notification-manager.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]

LABEL net.juniper.nodemgr.filter.name=ironic-notification-manager
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
