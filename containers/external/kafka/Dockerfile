ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
ARG KAFKA_DISTRO_NAME=kafka

ENV KAFKA_DIR=/opt/$KAFKA_DISTRO_NAME \
    KAFKA_CONF_DIR=/opt/$KAFKA_DISTRO_NAME/config \
    LOG_DIR=/var/log/kafka


RUN yum install -y java java-1.8.0-openjdk-devel iproute openssl kafka && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/docker-entrypoint.sh"]
WORKDIR $KAFKA_DIR
USER kafka:kafka
CMD ["bin/kafka-server-start.sh", "config/server.properties"]

ENV SERVICE_NAME=kafka
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
