ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail statistics client" \
      description="Contrail statistics client collects statistics about number of virtual networks, virtual routers , etc. No private information is collected."

COPY entrypoint.sh /
COPY / /src/

RUN yum install -y python2-setuptools && \
    cd src && \
    [[ -d 'stats' ]] || { yum install -y git; git clone --single-branch https://github.com/Juniper/contrail-controller.git; cd contrail-controller/src/; yum autoremove -y git; } && \
    cd stats && \
    python setup.py install && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    rm -rf /src

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-stats-client", "--config", "/etc/contrail/contrail-stats-client.conf"]

ENV SERVICE_NAME=stats
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
