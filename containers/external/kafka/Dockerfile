ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Kafka" \
      description="Contrail Kafka is used for streaming data in Analytics DB."

ARG KAFKA_DISTRO_NAME=kafka_2.11-1.1.1-1
ARG KAFKA_CACHE=https://github.com/Juniper/contrail-third-party-cache/blob/master/kafka

ENV KAFKA_DIR=/opt/$KAFKA_DISTRO_NAME \
    KAFKA_CONF_DIR=/opt/$KAFKA_DISTRO_NAME/etc/kafka \
    KAFKA_BIN_DIR=/opt/$KAFKA_DISTRO_NAME/usr/bin \
    LOG_DIR=/var/log/kafka \
    LIB_DIR=/var/lib/kafka \
    KAFKA_OPTS="-XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M" \
    KAFKA_USER=kafka \
    KAFKA_GROUP=kafka

RUN yum install -y java java-1.8.0-openjdk-devel iproute openssl && \
    curl -L -o $KAFKA_DISTRO_NAME.tgz $KAFKA_CACHE/$KAFKA_DISTRO_NAME.tar.gz?raw=true && \
    tar -xvf $KAFKA_DISTRO_NAME.tgz && \
    mkdir -p $KAFKA_DIR && \
    mv $KAFKA_DISTRO_NAME/* $KAFKA_DIR && \
    rm -f $KAFKA_DISTRO_NAME.tgz && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    groupadd -f -g 1011 kafka && adduser -M -g kafka kafka && \
    mkdir -p $LOG_DIR && \
    mkdir -p $LIB_DIR && \
    chown -R $KAFKA_USER:$KAFKA_GROUP $LOG_DIR && \
    chown -R $KAFKA_USER:$KAFKA_GROUP $LIB_DIR && \
    chown -R $KAFKA_USER:$KAFKA_GROUP $KAFKA_DIR

COPY *.sh /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/docker-entrypoint.sh"]
WORKDIR $KAFKA_DIR
CMD ["usr/bin/kafka-server-start", "etc/kafka/server.properties"]

ENV SERVICE_NAME=kafka
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
