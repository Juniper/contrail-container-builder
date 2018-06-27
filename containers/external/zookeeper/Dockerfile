FROM zookeeper:3.4.10

ARG CONTAINER_NAME

COPY *.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]

ENV SERVICE_NAME=zookeeper
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
