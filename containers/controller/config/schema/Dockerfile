ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}

LABEL summary="Controller Configuration Schema" \
	  description="Controller Configuration Schema provides the data model schema file for Controller Configuration REST API autogeneration." \
	  
ARG CONTAINER_NAME

COPY entrypoint.sh /

RUN yum clean all -y && \
    rm -rf /var/cache/yum

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-schema","--conf_file","/etc/contrail/contrail-schema.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]

ENV SERVICE_NAME=schema
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
