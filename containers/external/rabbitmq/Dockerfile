FROM rabbitmq:3.7.4

ARG CONTAINER_NAME

COPY contrail-entrypoint.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["rabbitmq-server"]

LABEL net.juniper.contrail.service=rabbitmq
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
