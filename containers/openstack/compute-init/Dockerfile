ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack Compute" \
      description="Sidecar container with libraries for nova-compute."

RUN rpm -Uvh --nodeps $(repoquery --location contrail-vrouter-agent) && \
    rpm -Uvh --nodeps $(repoquery --location contrail-nova-vif) && \
    mkdir -p /opt/contrail/bin /opt/contrail/site-packages && \
    cp /usr/bin/vrouter-port-control /opt/contrail/bin && \
    cp -rf /usr/lib/python2.7/site-packages/vif_plug_vrouter* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/vif_plug_contrail_vrouter* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/nova_contrail_vif* /opt/contrail/site-packages && \
    yum autoremove -y contrail-vrouter-agent contrail-nova-vif && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
