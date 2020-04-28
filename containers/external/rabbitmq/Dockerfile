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
      summary="Contrail RabbitMQ" \
      description="Contrail Rabbitmq is the message bus that different Contrail processes subscribe to."

COPY contrail-entrypoint.sh __*.sh hostname_to_ip /
COPY docker-entrypoint.sh /usr/local/bin/

RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash && \
    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash && \
    yum install erlang-21.3* rabbitmq-server-3.7.20* bind bind-utils vim-common -y && \
    usermod -a -G $CONTRAIL_GID rabbitmq && \
    yum clean all -y && \
    rm -rf /var/cache/yum

EXPOSE 15671 15672 4369 5671 5672 25672

ENTRYPOINT ["/contrail-entrypoint.sh"]

CMD ["rabbitmq-server"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
ENV SERVICE_NAME=rabbitmq
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
