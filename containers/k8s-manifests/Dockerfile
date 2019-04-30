ARG LINUX_DISTR=centos
ARG LINUX_DISTR_VER=7
FROM $LINUX_DISTR:$LINUX_DISTR_VER

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor="Juniper" \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail container builder repository." \
      description="The container generates Kubernetes manifest for Contrail installation and contains Contrail Container Builder repository."

COPY __licensing.txt /licenses/licensing.txt
COPY __contrail-container-builder /contrail-container-builder

RUN yum install -y iproute && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]