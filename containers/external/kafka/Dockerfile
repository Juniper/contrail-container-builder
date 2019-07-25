ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Kafka" \
      description="Contrail Kafka is used for streaming data in Analytics DB."

ARG KAFKA_DISTRO_NAME=kafka_2.11-0.9.0.1

ENV KAFKA_DIR=/opt/$KAFKA_DISTRO_NAME \
    KAFKA_CONF_DIR=/opt/$KAFKA_DISTRO_NAME/config \
    LOG_DIR=/var/log/kafka \
    KAFKA_OPTS="-XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M" \
    KAFKA_USER=kafka \
    KAFKA_GROUP=kafka

RUN yum install -y java java-1.8.0-openjdk-devel iproute openssl && \
    curl -o $KAFKA_DISTRO_NAME.tgz http://archive.apache.org/dist/kafka/0.9.0.1/$KAFKA_DISTRO_NAME.tgz && \
    tar -xvf $KAFKA_DISTRO_NAME.tgz && \
    mkdir -p $KAFKA_CONF_DIR && \
    mv $KAFKA_DISTRO_NAME/* $KAFKA_DIR && \
    rm -f $KAFKA_DISTRO_NAME.tgz && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    groupadd -f -g 1011 kafka && adduser -M -g kafka kafka && \
    mkdir -p $LOG_DIR && \
    chown -R $KAFKA_USER:$KAFKA_GROUP $LOG_DIR && \
    chown -R $KAFKA_USER:$KAFKA_GROUP $KAFKA_DIR

COPY *.sh /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/docker-entrypoint.sh"]
WORKDIR $KAFKA_DIR
CMD ["bin/kafka-server-start.sh", "config/server.properties"]

ENV SERVICE_NAME=kafka
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
