ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ARG CONTAINER_NAME
ENV PYTHON_SETUP_DIR="/opt/contrail/"
LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack neutron-server" \
      description="Sidecar container with libraries for neutron-server."

ARG LINUX_DISTR
# run _prepare_packages.sh as a last step cause it can break some repositories
RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
    rpm -Uvh --nodeps $(repoquery --location python-contrail) && \
    rpm -Uvh --nodeps $(repoquery --location neutron-plugin-contrail) && \
    mkdir -p /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/neutron_plugin_contrail* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/cfgm_common* /opt/contrail/site-packages && \
    yum remove -y python-contrail neutron-plugin-contrail && \
    /_prepare_packages.sh && rm -f /_prepare_packages.sh && \
    yum autoremove -y && yum clean all -y && \
    rm -rf /var/cache/yum; \
    fi

COPY *.sh /
ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
