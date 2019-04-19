ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail DHCP" \
      description="Image with DHCP implementation for Contrail Device Manager."

RUN yum install -y dhcp && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/dhcpd", "-f", "-d", "-cf", "/etc/dhcp/dhcpd.conf", "--no-pid"]

ENV SERVICE_NAME=dhcp
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
