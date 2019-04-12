ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Controller Configuration REST API" \
      description="All configuration cluster is available through a REST API that is accessed on port 8082 of the external virtual IP address."

RUN yum install -y python-neutron-lib && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-api","--conf_file","/etc/contrail/contrail-api.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf","--worker_id","0"]

ENV SERVICE_NAME=api
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
