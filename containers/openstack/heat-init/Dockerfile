ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack Heat" \
      description="Sidecar container with libraries for heat services."

COPY *.sh /

RUN BASE_EXTRA_RPMS=$(echo $BASE_EXTRA_RPMS | tr -d '"' | tr ',' ' ') && \
    if [[ -n "$BASE_EXTRA_RPMS" ]] ; then \
        echo "INFO: openstack/neutron-init: install $BASE_EXTRA_RPMS" ; \
        yum install -y $BASE_EXTRA_RPMS ; \
    fi && \
    mkdir -p /opt/contrail/site-packages && \
    if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
    rpm -Uvh --nodeps $(repoquery --location python-contrail) && \
    rpm -Uvh --nodeps $(repoquery --location contrail-heat) && \
    cp -rf /usr/lib/python2.7/site-packages/contrail_heat* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail/site-packages && \
    yum autoremove -y python-contrail contrail-heat && \
    mkdir -p /tmp/future && pushd /tmp/future && \
    yumdownloader python2-future && \
    rpm2cpio $(ls python2-future*.rpm) | cpio -iuvd && \
    cp -r usr/lib/python2.7/site-packages /opt/contrail/ && \
    popd && rm -rf /tmp/future && \
    yum clean all -y && \
    rm -rf /var/cache/yum; \
    fi

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
