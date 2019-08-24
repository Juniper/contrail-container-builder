ARG CONTRAIL_BASE_REGISTRY
ARG CONTRAIL_BASE_CONTAINER_TAG
FROM ${CONTRAIL_BASE_REGISTRY}/contrail-base:${CONTRAIL_BASE_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Kubernetes Container Network Interface" \
      description="Contrail provides support for Container Network Interface for Kubernetes."

RUN curl -sSL --retry 5 -o /opt/cni-v0.3.0.tgz https://github.com/containernetworking/cni/releases/download/v0.3.0/cni-v0.3.0.tgz && \
    yum install -y contrail-k8s-cni \
                   contrail-lib \
                   contrail-setup \
                   contrail-utils \
                   python-contrail && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
