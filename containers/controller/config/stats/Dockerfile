ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail statistics client" \
      description="Contrail statistics client collects statistics about number of virtual networks, virtual routers , etc. No private information is collected."

COPY entrypoint.sh /

RUN yum install -y python2-setuptools git && \
    [[ -d 'stats' ]] || { git clone https://github.com/Juniper/contrail-controller.git; cd contrail-controller/src/; } && \
    cd stats && \
    python setup.py install && \
    python setup.py install_lib && \
    yum autoremove -y git && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    rm -rf /contrail-controller

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-stats-client", "--config", "/etc/contrail/contrail-stats-client.conf"]

ENV SERVICE_NAME=stats
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
