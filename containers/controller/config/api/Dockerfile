ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
ARG CONTRAIL_BUILD_FROM_SOURCE
LABEL name=$CONTAINER_NAME \
      summary="Contrail Controller Configuration API" \
      description="Controller Configuration API provides a REST API to an orchestration system."

# contrail-config-openstack contains svc_monitor and vnc_openstack modules
RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]]; then \
      yum install -y python-neutron-lib && \
      yum clean all -y && \
      rm -rf /var/cache/yum && \
      find / -name '__pycache__' -delete -o -name "*.pyc" -delete -o -name "*.pyo" -delete ;\
    fi

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-api", "--conf_file", "/etc/contrail/contrail-api.conf", "--conf_file", "/etc/contrail/contrail-keystone-auth.conf", "--worker_id", "0"]

ENV SERVICE_NAME=api
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME