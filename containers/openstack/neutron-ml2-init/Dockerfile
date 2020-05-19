ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
ARG LINUX_DISTR

LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack neutron-server with ml2 driver" \
      description="Sidecar container with libraries for neutron-server with ml2 driver."

COPY *.sh /

# run _prepare_packages.sh as a last step cause it can break some repositories
RUN curl https://bootstrap.pypa.io/get-pip.py | python2 && \
    pip install --target=/opt/contrail/site-packages future && \
    mkdir -p /opt/contrail/site-packages && \
    rpm -Uvh --nodeps $(repoquery --location python-contrail) && \
    rpm -Uvh --nodeps $(repoquery --location tf-neutron-ml2-plugin) && \
    cp -rf /usr/lib/python2.7/site-packages/networking_opencontrail* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/cfgm_common* /opt/contrail/site-packages && \
    yum autoremove -y python-contrail tf-neutron-ml2-plugin && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
