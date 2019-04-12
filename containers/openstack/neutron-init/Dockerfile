ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-openstack-neutron-init" \
      summary="Contrail Openstack Neutron" \
      description="Plugin for OpenStack implements the Neutron API."

ARG CONTAINER_NAME
ARG LINUX_DISTR

COPY *.sh /

# run _prepare_packages.sh as a last step cause it can break some repositories
RUN yum install -y neutron-plugin-contrail && \
    /_prepare_packages.sh && rm -f /_prepare_packages.sh && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
