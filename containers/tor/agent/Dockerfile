ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-tor-agent" \
      summary="ToR agent" \
      description="A ToR agent provisioned in the Contrail cluster acts as the OVSDB client for the ToR switch, \n\
                  and all of the OVSDB interactions with the ToR switch are performed by using the ToR agent."

ARG CONTAINER_NAME

RUN yum install -y contrail-vrouter-agent python-contrail-vrouter-api openssl && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-tor-agent","--config_file","/etc/contrail/contrail-tor-agent.conf"]

ENV SERVICE_NAME=tor-agent
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
