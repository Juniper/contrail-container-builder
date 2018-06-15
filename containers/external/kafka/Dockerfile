ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
ARG KAFKA_DISTRO_NAME=kafka_2.11-1.1.1-1
ARG KAFKA_CACHE=https://github.com/Juniper/contrail-third-party-cache/blob/master/kafka

ENV KAFKA_DIR=/opt/$KAFKA_DISTRO_NAME \
    KAFKA_CONF_DIR=/opt/$KAFKA_DISTRO_NAME/etc/kafka \
    LOG_DIR=/var/log/kafka


RUN yum install -y java iproute wget && \
    wget -O $KAFKA_DISTRO_NAME.tgz $KAFKA_CACHE/$KAFKA_DISTRO_NAME.tar.gz?raw=true && \
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
CMD ["usr/bin/kafka-server-start", "etc/kafka/server.properties"]

LABEL net.juniper.contrail.service=kafka
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
