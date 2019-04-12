ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-mesosphere-mesos-manager" \
      summary="Mesosphere Manager" \
      description="In Mesos, mesos manager will update all information regarding task (universal docker) to Contrail Controller via API server."

ARG CONTAINER_NAME

RUN yum install -y python-eventlet python-setuptools python-kazoo \
                   python-bitarray python-pycassa python-bitstring \
                   contrail-mesos-manager python-enum34 && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-mesos-manager", "-c", "/etc/contrail/contrail-mesos.conf"]

ENV NODE_TYPE=mesosphere
ENV SERVICE_NAME=mesos-manager
LABEL net.juniper.contrail.pod=$NODE_TYPE
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
