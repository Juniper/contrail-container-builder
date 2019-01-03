ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
ARG PYTHON_PIP_RPM=python-pip
ARG PYTHON_PIP_VENV=""

RUN yum install -y python-neutron-lib $PYTHON_PIP_RPM && \
    if [[ -n "$PYTHON_PIP_VENV" ]] ; then \
        source $PYTHON_PIP_VENV ; \
    fi && \
    pip install --upgrade pip && \
    pip install "inflection>=0.3.1" "jxmlease>=1.0.1" "junos-eznc>=2.1.7" "timeout_decorator>=0.4.0" "python-jsonschema-objects>=0.3.3" "attrdict" && \
    ansible-galaxy install Juniper.junos && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-api","--conf_file","/etc/contrail/contrail-api.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf","--worker_id","0"]

ENV SERVICE_NAME=api
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
