ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

RUN easy_install pip==18.1 && \
    pip install "inflection>=0.3.1" "jxmlease>=1.0.1" "junos-eznc>=2.1.7" "timeout_decorator>=0.4.0" "python-jsonschema-objects>=0.3.3" && \
    ansible-galaxy install Juniper.junos && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-device-manager","--conf_file","/etc/contrail/contrail-device-manager.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]

ENV SERVICE_NAME=device-manager
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
