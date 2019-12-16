ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Mesosphere Manager" \
      description="Contrail Mesosphere Manager."

RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
      yum install -y python-eventlet python-setuptools python-kazoo \
                     python-bitarray python-pycassa python-bitstring \
                     contrail-mesos-manager python-enum34 && \
      yum clean all -y && \
      rm -rf /var/cache/yum && \
      find / -name '__pycache__' -delete -o -name "*.pyc" -delete -o -name "*.pyo" -delete ;\
    fi

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-mesos-manager", "-c", "/etc/contrail/contrail-mesos.conf"]

ENV NODE_TYPE=mesosphere
ENV SERVICE_NAME=mesos-manager
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
