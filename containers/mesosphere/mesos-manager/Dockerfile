ARG CONTRAIL_BASE_REGISTRY
ARG CONTRAIL_BASE_CONTAINER_TAG
FROM ${CONTRAIL_BASE_REGISTRY}/contrail-base:${CONTRAIL_BASE_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Mesosphere Manager" \
      description="Contrail Mesosphere Manager."

RUN yum install -y python-eventlet python-setuptools python-kazoo \
                   python-bitarray python-pycassa python-bitstring \
                   contrail-mesos-manager python-enum34 \
                   contrail-lib \
                   contrail-setup \
                   contrail-utils \
                   python-contrail && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-mesos-manager", "-c", "/etc/contrail/contrail-mesos.conf"]

ENV NODE_TYPE=mesosphere
ENV SERVICE_NAME=mesos-manager
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
