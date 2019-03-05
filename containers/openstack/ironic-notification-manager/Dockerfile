ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

RUN yum install --cacheonly -y ironic-notification-manager && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/ironic-notification-manager","--conf_file","/etc/contrail/ironic-notification-manager.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
