ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Mesosphere Container Network Interface" \
      description="Contrail supports Mesosphere Container Network Interface."

RUN curl -sSL --retry 5 -o /opt/cni-v0.3.0.tgz https://github.com/containernetworking/cni/releases/download/v0.3.0/cni-v0.3.0.tgz && \
    if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
      yum install -y contrail-mesos-cni && \
      yum clean all -y && \
      rm -rf /var/cache/yum && \
      find / -name '__pycache__' -delete -o -name "*.pyc" -delete -o -name "*.pyo" -delete ;\
    fi
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
