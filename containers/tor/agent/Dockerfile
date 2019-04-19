ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail ToR agent" \
      description="A ToR agent provisioned in the Contrail cluster acts as the OVSDB client for the ToR switch, and all of the OVSDB interactions with the ToR switch are performed by using the ToR agent."

RUN yum install -y contrail-vrouter-agent python-contrail-vrouter-api openssl && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-tor-agent","--config_file","/etc/contrail/contrail-tor-agent.conf"]

ENV NODE_TYPE=toragent
LABEL net.juniper.contrail.pod=$NODE_TYPE

ENV SERVICE_NAME=tor-agent
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
