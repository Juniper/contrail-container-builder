ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-kubernetes-cni-init" \
      summary="Kubernetes Container Network Interface" \
      description="Contrail provides support for CNI for Kubernetes."

ARG CONTAINER_NAME

RUN curl -sSL --retry 5 -o /opt/cni-v0.3.0.tgz https://github.com/containernetworking/cni/releases/download/v0.3.0/cni-v0.3.0.tgz && \
    yum install -y contrail-k8s-cni && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
