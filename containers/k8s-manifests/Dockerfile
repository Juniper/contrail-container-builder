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

ARG GENERAL_EXTRA_RPMS=""
ARG YUM_ENABLE_REPOS=""

# this copy should be before yum install
COPY *.repo /etc/yum.repos.d/

RUN YUM_ENABLE_REPOS=$(echo $YUM_ENABLE_REPOS | tr -d '"') && \
    if [[ -n "$YUM_ENABLE_REPOS" ]] ; then \
        echo "INFO: contrail-k8s-manifests: enable repos $YUM_ENABLE_REPOS" && \
        yum-config-manager --enable $YUM_ENABLE_REPOS ; \
        yum clean metadata ; \
    fi && \
    yum install -y iproute && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
