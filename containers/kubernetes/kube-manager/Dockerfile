ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-kubernetes-kube-manager" \
      summary="contrail-kube-manager" \
      description="contrail-kube-manager runs in a Docker container to listen to the messages from the Kubernetes API server."

ARG CONTAINER_NAME

RUN yum install -y python-eventlet python-setuptools python-kazoo \
                   python-bitarray python-pycassa python-bitstring \
                   contrail-kube-manager python-enum34 && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-kube-manager", "-c", "/etc/contrail/contrail-kubernetes.conf"]

ENV NODE_TYPE=kubernetes
ENV SERVICE_NAME=kube-manager
LABEL net.juniper.contrail.pod=$NODE_TYPE
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
