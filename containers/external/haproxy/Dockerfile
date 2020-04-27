ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG VENDOR_NAME

ARG CONTAINER_NAME
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail HAProxy" \
      description="Contrail HAProxy supports high availability for Contrail container subsystems."

# Add required license as text1 file in Liceses directory
RUN yum install -y haproxy

COPY *.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
ENV SERVICE_NAME=haproxy
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
