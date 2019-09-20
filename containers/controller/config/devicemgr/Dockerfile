ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Device Manager" \
      description="Contrail Device Manager is used to manage network devices in the Contrail system."

ARG CONTRAIL_BUILD_FROM_SOURCE
RUN easy_install pip && \
    pip install "inflection>=0.3.1" "jxmlease>=1.0.1" "ncclient==0.6.3" "junos-eznc>=2.1.7,<=2.2.0" "timeout_decorator>=0.4.0" "python-jsonschema-objects>=0.3.3" "jsnapy>=1.3.2" "ansible==2.6.13" && \
    ansible-galaxy install Juniper.junos && \
    if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]]; then \
    sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf && \   
    yum install -y iputils && \
    yum clean all -y && \
    rm -rf /var/cache/yum; \
    fi

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-device-manager", "--conf_file", "/etc/contrail/contrail-device-manager.conf", "--conf_file", "/etc/contrail/contrail-keystone-auth.conf"]

ENV SERVICE_NAME=device-manager
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME

