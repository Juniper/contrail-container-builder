ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

COPY entrypoint.sh /
COPY setup /setup/
RUN yum install -y python2-setuptools && \
    cd /setup/ && \
    python setup.py install && \
    python setup.py install_lib && \
    yum clean all -y && \
    rm -rf /var/cache/yum
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-stats-client", "--config", "/etc/contrail/contrail-stats-client.conf"]

LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME

