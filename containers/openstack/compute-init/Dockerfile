ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ARG CONTAINER_NAME
ENV PYTHON_SETUP_DIR="/opt/contrail/"
LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack Compute" \
      description="Sidecar container with libraries for nova-compute."

RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
    rpm -Uvh --nodeps $(repoquery --location contrail-vrouter-agent) && \
    rpm -Uvh --nodeps $(repoquery --location contrail-nova-vif) && \
    mkdir -p /opt/contrail/bin && \
    cp /usr/bin/vrouter-port-control /opt/contrail/bin && \
    mkdir -p /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/vif_plug_vrouter* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/vif_plug_contrail_vrouter* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/nova_contrail_vif* /opt/contrail/site-packages && \
    yum autoremove -y contrail-vrouter-agent contrail-nova-vif && \
    yum clean all -y && \
    rm -rf /var/cache/yum; \    
    fi
COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
