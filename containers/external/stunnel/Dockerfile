ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL vendor="Juniper" \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail Stunnel" \
      description="Contrail Stunnel provides encryption to Redis"

COPY *.sh /

RUN yum install -y openssl stunnel

ADD stunnel.conf /etc/stunnel/

ENTRYPOINT ["/contrail-entrypoint.sh"]
RUN ["chmod", "+x", "/contrail-entrypoint.sh"]

ENV SERVICE_NAME=stunnel
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
