FROM ${CONTRAIL_REGISTRY}/contrail-controller-database-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

ENV ZOO_USER=zookeeper \
    ZOO_CONF_DIR=/conf \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_PORT=2181 \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2

# Add a user and make dirs
RUN set -x \
    && adduser "$ZOO_USER" \
    && mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" \
    && chown "$ZOO_USER:$ZOO_USER" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR"

ARG ZOOKEEPER_VERSION=3.4.11

RUN curl -o zookeeper-$ZOOKEEPER_VERSION.tar.gz http://www.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz \
    && tar -xzf "zookeeper-$ZOOKEEPER_VERSION.tar.gz" \
    && mv "zookeeper-$ZOOKEEPER_VERSION/conf/"* "$ZOO_CONF_DIR" \
    && rm -r "zookeeper-$ZOOKEEPER_VERSION.tar.gz"

WORKDIR /zookeeper-$ZOOKEEPER_VERSION
VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR"]

EXPOSE $ZOO_PORT 2888 3888

ENV PATH=$PATH:/zookeeper-$ZOOKEEPER_VERSION/bin \
    ZOOCFGDIR=$ZOO_CONF_DIR

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]
