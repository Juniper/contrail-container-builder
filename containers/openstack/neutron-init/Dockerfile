ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack neutron-server" \
      description="Sidecar container with libraries for neutron-server."

ARG LINUX_DISTR
COPY *.sh /
# run _prepare_packages.sh as a last step cause it can break some repositories
RUN curl https://bootstrap.pypa.io/get-pip.py | python2 && \
    BASE_EXTRA_RPMS=$(echo $BASE_EXTRA_RPMS | tr -d '"' | tr ',' ' ') && \
    if [[ -n "$BASE_EXTRA_RPMS" ]] ; then \
        echo "INFO: openstack/neutron-init: install $BASE_EXTRA_RPMS" ; \
        yum install -y $BASE_EXTRA_RPMS ; \
    fi && \
    mkdir -p /opt/contrail/site-packages && \
    if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
    rpm -Uvh --nodeps $(repoquery --location python-contrail) && \
    rpm -Uvh --nodeps $(repoquery --location neutron-plugin-contrail) && \
    cp -rf /usr/lib/python2.7/site-packages/neutron_plugin_contrail* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail/site-packages && \
    yum remove -y python-contrail neutron-plugin-contrail && \
    mkdir -p /tmp/future && pushd /tmp/future && \
    yumdownloader python2-future && \
    rpm2cpio $(ls python2-future*.rpm) | cpio -iuvd && \
    cp -r usr/lib/python2.7/site-packages /opt/contrail/ && \
    popd && rm -rf /tmp/future && \
    /_prepare_packages.sh && rm -f /_prepare_packages.sh && \
    yum autoremove -y && yum clean all -y && \
    rm -rf /var/cache/yum; \
    fi && \
    /_prepare_packages.sh && rm -f /_prepare_packages.sh

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
