ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack neutron-server" \
      description="Sidecar container with libraries for neutron-server."

ARG LINUX_DISTR

COPY *.sh /

# run _prepare_packages.sh as a last step cause it can break some repositories
RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
    yum install -y neutron-plugin-contrail && \
    /_prepare_packages.sh && rm -f /_prepare_packages.sh && \
    yum clean all -y && \
    rm -rf /var/cache/yum; \
    fi
ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
