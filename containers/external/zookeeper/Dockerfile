FROM zookeeper:3.4.10

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor="Juniper" \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.0" \
      name=$CONTAINER_NAME \
      summary="Contrail Zookeeper" \
      description="Contrail uses the Apache ZooKeeper process to maintain synchronization of Contrail configuration, analytics and database running on the different instances of controllers."

COPY *.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]

ENV SERVICE_NAME=zookeeper
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
