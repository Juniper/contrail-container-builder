ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME

LABEL name=$CONTAINER_NAME \
      summary="Contrail RabbitMQ" \
      description="Contrail Rabbitmq is the message bus that different Contrail processes subscribe to."

COPY *.sh hostname_to_ip /

# vim-common is needed because of xxd tool
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash && \
    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash && \
    yum install -y erlang-21.3* rabbitmq-server-3.7.20* bind bind-utils perl vim-common && \
    usermod -a -G $CONTRAIL_GID rabbitmq && \
    usermod -d /var/lib/rabbitmq rabbitmq && \
    rabbitmq-plugins enable --offline rabbitmq_management && \
    yum clean all -y && \
    rm -rf /var/cache/yum

VOLUME "/var/lib/rabbitmq"

EXPOSE 15671 15672 4369 5671 5672 25672

ENTRYPOINT ["/contrail-entrypoint.sh"]

CMD ["rabbitmq-server"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG \
    SERVICE_NAME=rabbitmq \
    RABBITMQ_LOGS=- \
    RABBITMQ_SASL_LOGS=-

LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME \
      $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
