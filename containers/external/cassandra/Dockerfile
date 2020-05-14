#FROM cassandra:3.11.3
ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME

LABEL name=$CONTAINER_NAME \
      summary="Contrail Cassandra DB" \
      description="Configuration database for Contrail Controller."

ENV CASSANDRA_HOME=/opt/cassandra \
    CASSANDRA_CONF=/etc/cassandra \
    PATH="$CASSANDRA_HOME/bin:$PATH" \
    CASSANDRA_LIB=/var/lib/cassandra \
    CASSANDRA_LOG=/var/log/cassandra \
    CASSANDRA_USER=cassandra \
    CASSANDRA_GROUP=cassandra
    
ARG CASSANDRA_VERSION=3.11.3
ARG DIST_URL="https://archive.apache.org/dist/cassandra/$CASSANDRA_VERSION/apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz"

COPY *.sh /

RUN set -eux && for item in `ls /__*` ; do mv $item /${item:3} ; done && \
    yum install -y java java-1.8.0-openjdk-devel iproute jemalloc numactl procps-ng less hostname openssl wget && \
    groupadd -f -g 1014 ${CASSANDRA_GROUP} && adduser -M -g ${CASSANDRA_GROUP} ${CASSANDRA_USER} && \
    usermod -a -G $CONTRAIL_GID ${CASSANDRA_USER} && \    
    wget -nv --tries=3 -c $DIST_URL && \
    mkdir -p ${CASSANDRA_HOME} $CASSANDRA_CONF ${CASSANDRA_LOG} ${CASSANDRA_LIB} && \
    tar -xzf apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz -C ${CASSANDRA_HOME} --strip-components 1 && \
    rm -rf  cassandra-$CASSANDRA_VERSION-bin.tar.gz && \
    mv "$CASSANDRA_HOME/conf" $CASSANDRA_CONF && \
	ln -sT "$CASSANDRA_CONF" "$CASSANDRA_HOME/conf" && \	
	chown -R ${CASSANDRA_GROUP}:${CASSANDRA_USER} $CASSANDRA_CONF ${CASSANDRA_LOG} ${CASSANDRA_LIB}  && \
	chmod 777 $CASSANDRA_CONF ${CASSANDRA_LOG} ${CASSANDRA_LIB} && \
	ln -sT ${CASSANDRA_LIB} "$CASSANDRA_HOME/data" && \
	ln -sT ${CASSANDRA_LOG}"$CASSANDRA_HOME/logs" && \
	yum clean all -y && \
    rm -rf /var/cache/yum && \    
# smoke test
	cassandra -v && \
    set +eux


VOLUME $CASSANDRA_LIB
ENTRYPOINT ["/contrail-entrypoint.sh"]
# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

CMD ["cassandra", "-f"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
ENV SERVICE_NAME=cassandra
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
