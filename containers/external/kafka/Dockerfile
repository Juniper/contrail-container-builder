ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Kafka" \
      description="Contrail Kafka is used for streaming data in Analytics DB."

ARG KAFKA_DISTRO_NAME=kafka_2.11-2.3.1
ARG KAFKA_CACHE=https://github.com/Juniper/contrail-third-party-cache/blob/master/kafka

ENV KAFKA_DIR=/opt/$KAFKA_DISTRO_NAME \
    KAFKA_CONF_DIR=/opt/$KAFKA_DISTRO_NAME/config \
    LOG_DIR=/var/log/kafka \
    KAFKA_OPTS="-XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M" \
    KAFKA_USER=kafka \
    KAFKA_GROUP=kafka

RUN yum install -y java java-1.8.0-openjdk-devel iproute less hostname python3 openssl wget && \
    wget -nv --tries=3 -c -O $KAFKA_DISTRO_NAME.tgz $KAFKA_CACHE/$KAFKA_DISTRO_NAME.tgz?raw=true && \
    tar -xvf $KAFKA_DISTRO_NAME.tgz && \
    mkdir -p $KAFKA_CONF_DIR && \
    mv $KAFKA_DISTRO_NAME/* $KAFKA_DIR && \
    rm -f $KAFKA_DISTRO_NAME.tgz && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    groupadd -f -g 1011 kafka && adduser -M -g kafka kafka && \
    usermod -a -G $CONTRAIL_GID $KAFKA_USER && \
    mkdir -p $LOG_DIR && \
    chown -R $KAFKA_USER:$KAFKA_GROUP $LOG_DIR && \
    chown -R $KAFKA_USER:$KAFKA_GROUP $KAFKA_DIR

COPY *.sh /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/docker-entrypoint.sh"]
WORKDIR $KAFKA_DIR
CMD ["bin/kafka-server-start.sh", "config/server.properties"]

ENV SERVICE_NAME=kafka
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
