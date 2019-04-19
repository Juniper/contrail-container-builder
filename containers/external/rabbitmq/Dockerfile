FROM rabbitmq:3.6.10

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor="Juniper" \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.0" \
      name=$CONTAINER_NAME \
      summary="Contrail RabbitMQ" \
      description="Contrail Rabbitmq is the message bus that different Contrail processes subscribe to."

# due to changes in debian repos apt-transport-https is needed for
# update but it can't be installed without update. thus error in
# first update should be ignored.
RUN apt-get update || /bin/true && \
         apt-get -fy install bind9-host

COPY contrail-entrypoint.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["rabbitmq-server"]

ENV SERVICE_NAME=rabbitmq
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
