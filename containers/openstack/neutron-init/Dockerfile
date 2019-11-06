ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
ARG LINUX_DISTR

LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack neutron-server" \
      description="Sidecar container with libraries for neutron-server."

COPY *.sh /

# run _prepare_packages.sh as a last step cause it can break some repositories
RUN curl https://bootstrap.pypa.io/get-pip.py | python2 && \
    pip install --target=/opt/contrail/site-packages future && \    
    mkdir -p /opt/contrail/site-packages && \
    rpm -Uvh --nodeps $(repoquery --location python-contrail) && \
    rpm -Uvh --nodeps $(repoquery --location neutron-plugin-contrail) && \
    cp -rf /usr/lib/python2.7/site-packages/neutron_plugin_contrail* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail/site-packages && \
    yum remove -y python-contrail neutron-plugin-contrail && \
    yum autoremove -y && yum clean all -y && \
    rm -rf /var/cache/yum && \
    /_prepare_packages.sh && rm -f /_prepare_packages.sh

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
