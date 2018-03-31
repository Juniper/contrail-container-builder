ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
ARG KAFKA_DISTRO_NAME=kafka_2.11-0.9.0.1

ENV KAFKA_DIR=/opt/$KAFKA_DISTRO_NAME \
    KAFKA_CONF_DIR=/opt/$KAFKA_DISTRO_NAME/config \
    LOG_DIR=/var/log/kafka


RUN yum install -y java iproute && \
    curl -o $KAFKA_DISTRO_NAME.tgz http://archive.apache.org/dist/kafka/0.9.0.1/$KAFKA_DISTRO_NAME.tgz && \
    tar -xvf $KAFKA_DISTRO_NAME.tgz && \
    mkdir -p $KAFKA_CONF_DIR && \
    mv $KAFKA_DISTRO_NAME/* $KAFKA_DIR && \
    rm -f $KAFKA_DISTRO_NAME.tgz && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    groupadd -f -g 999 kafka && adduser -M -g kafka kafka && \
    mkdir -p $LOG_DIR && \
    chown -R kafka:kafka $LOG_DIR && \
    chown -R kafka:kafka $KAFKA_DIR

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
WORKDIR $KAFKA_DIR
USER kafka:kafka
CMD ["bin/kafka-server-start.sh", "config/server.properties"]

LABEL net.juniper.contrail.service=kafka
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
