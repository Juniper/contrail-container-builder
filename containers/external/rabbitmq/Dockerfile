FROM rabbitmq:3.6.10-management

ARG CONTAINER_NAME

RUN apt-get update && apt-get -fy install bind9-host

COPY *.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["rabbitmq-server"]

ENV SERVICE_NAME=rabbitmq
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
