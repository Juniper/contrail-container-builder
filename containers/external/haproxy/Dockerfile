FROM haproxy:1.7

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor="Juniper" \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail HAProxy" \
      description="Contrail supports high availability for Contrail container subsystems."

COPY *.sh /

RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]

ENV SERVICE_NAME=haproxy
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
