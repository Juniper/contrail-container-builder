ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail TFTP" \
      description="Image with TFTP implementation for Contrail Controller Device Manager."

RUN yum install -y tftp-server && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENV SERVER_IP=0.0.0.0
ENV SERVER_PORT=69

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/in.tftpd", "-s", "/var/lib/tftpboot", "-L", "-a", "$SERVER_IP:$SERVER_PORT"]

ENV SERVICE_NAME=tftp
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
