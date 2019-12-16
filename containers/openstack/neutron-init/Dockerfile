ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack neutron-server" \
      description="Sidecar container with libraries for neutron-server."

ARG LINUX_DISTR

COPY *.sh /

# run _prepare_packages.sh as a last step cause it can break some repositories
# python2-future is required for python-contrail
RUN rpm -Uvh --nodeps $(repoquery --location python-contrail) && \
    rpm -Uvh --nodeps $(repoquery --location neutron-plugin-contrail) && \
    mkdir -p /opt/contrail/site-packages && \
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
    rm -rf /var/cache/yum && \
    find / -name '__pycache__' -delete -o -name "*.pyc" -delete -o -name "*.pyo" -delete

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
