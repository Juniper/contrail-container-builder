ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
ARG KAFKA_DISTRO_NAME=kafka_2.11-1.1.1-1
ARG KAFKA_CACHE=https://github.com/Juniper/contrail-third-party-cache/blob/master/kafka

ENV KAFKA_DIR=/opt/$KAFKA_DISTRO_NAME \
    KAFKA_CONF_DIR=/opt/$KAFKA_DISTRO_NAME/etc/kafka \
    KAFKA_BIN_DIR=/opt/$KAFKA_DISTRO_NAME/usr/bin \
    LOG_DIR=/var/log/kafka \
    LIB_VAR_DIR=/var/lib/kafka


RUN yum install -y java java-1.8.0-openjdk-devel iproute && \
    curl -L -o $KAFKA_DISTRO_NAME.tgz $KAFKA_CACHE/$KAFKA_DISTRO_NAME.tar.gz?raw=true && \
    tar -xvf $KAFKA_DISTRO_NAME.tgz && \
    mkdir -p $KAFKA_DIR && \
    mv $KAFKA_DISTRO_NAME/* $KAFKA_DIR && \
    rm -f $KAFKA_DISTRO_NAME.tgz && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    groupadd -f -g 999 kafka && adduser -M -g kafka kafka && \
    mkdir -p $LOG_DIR && \
    mkdir -p $LIB_VAR_DIR && \
    chown -R kafka:kafka $LOG_DIR && \
    chown -R kafka:kafka $LIB_VAR_DIR && \
    chown -R kafka:kafka $KAFKA_DIR

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
WORKDIR $KAFKA_DIR
USER kafka:kafka
CMD ["usr/bin/kafka-server-start", "etc/kafka/server.properties"]

LABEL net.juniper.contrail.service=kafka
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME

