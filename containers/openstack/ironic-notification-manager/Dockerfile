ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Ironic Notification Manager for OpenStack" \
      description="OpenStack bare metal provisioning a.k.a Ironic is an integrated OpenStack program which aims to provision bare metal machines instead of virtual machines, forked from the Nova baremetal driver."

RUN curl https://bootstrap.pypa.io/get-pip.py | python2 && \
    if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
    yum install -y ironic-notification-manager && \
    yum clean all -y && \
    rm -rf /var/cache/yum; \
    fi

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/ironic-notification-manager", "--conf_file", "/etc/contrail/ironic-notification-manager.conf", "--conf_file", "/etc/contrail/contrail-keystone-auth.conf"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
