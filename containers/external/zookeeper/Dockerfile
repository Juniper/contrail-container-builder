ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME

LABEL name=$CONTAINER_NAME \
      summary="Contrail Zookeeper" \
      description="Contrail uses the Apache ZooKeeper process to maintain synchronization of Contrail configuration, analytics and database running on the different instances of controllers."

ENV ZOO_CONF_DIR=/conf \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_LOG_DIR=/logs \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2 \
    ZOO_AUTOPURGE_PURGEINTERVAL=0 \
    ZOO_AUTOPURGE_SNAPRETAINCOUNT=3 \
    ZOO_MAX_CLIENT_CNXNS=60 \
    ZOO_URL="https://archive.apache.org/dist/zookeeper" \
    ZOO_USER="zookeeper" \
    ZOO_GROUP="zookeeper"

ARG ZOO_VERSION="3.6.1"
ARG ZOO_DISTRO_NAME="apache-zookeeper-${ZOO_VERSION}-bin"

ENV PATH=$PATH:/${ZOO_DISTRO_NAME}/bin \
    ZOOCFGDIR=$ZOO_CONF_DIR

COPY *.sh hostname_to_ip /

RUN set -eux && for item in `ls /__*` ; do mv $item /${item:3} ; done && \
    yum install -y java java-1.8.0-openjdk iproute perl nmap-ncat openssl wget && \
    groupadd -f -g 1000 $ZOO_GROUP && adduser -u 1000 -M -g $ZOO_GROUP $ZOO_USER && \
    usermod -a -G $CONTRAIL_GID $ZOO_USER && \
    mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" "$ZOO_LOG_DIR" && \
    chown -R ${ZOO_USER}:${ZOO_GROUP} "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" "$ZOO_LOG_DIR" && \
    wget -nv --tries=3 -c -O ${ZOO_DISTRO_NAME}.tar.gz ${ZOO_URL}/zookeeper-${ZOO_VERSION}/${ZOO_DISTRO_NAME}.tar.gz && \
    tar -xzvf $ZOO_DISTRO_NAME.tar.gz && \
    rm -rf  $ZOO_DISTRO_NAME.tar.gz && \
    mv "${ZOO_DISTRO_NAME}/conf/"* "$ZOO_CONF_DIR" && \
    chown -R ${ZOO_USER}:${ZOO_GROUP} $ZOO_DISTRO_NAME && \
    yum clean all -y && \
    rm -rf /var/cache/yum

WORKDIR ${ZOO_DISTRO_NAME}

VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR", "$ZOO_LOG_DIR"]

EXPOSE 2181 2888 3888

ENTRYPOINT ["/contrail-entrypoint.sh"]

CMD ["zkServer.sh", "start-foreground"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
ENV SERVICE_NAME=zookeeper
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
