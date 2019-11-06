ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack Compute" \
      description="Sidecar container with libraries for nova-compute."

RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
    yum install -y contrail-vrouter-agent contrail-nova-vif && \
    mkdir -p /opt/contrail/bin && \
    cp /usr/bin/vrouter-port-control /opt/contrail/bin && \
    yum remove -y contrail-vrouter-agent && \
    yum autoremove -y && yum clean all -y && \
    rm -rf /var/cache/yum; \
    fi
COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
