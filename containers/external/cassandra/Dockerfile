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
    PATH="$CASSANDRA_HOME/bin:$PATH"
    
ARG CASSANDRA_VERSION=3.11.3
ARG DIST_URL="https://archive.apache.org/dist/cassandra/$CASSANDRA_VERSION/apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz"

COPY *.sh /

RUN bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    yum install -y java java-1.8.0-openjdk-devel iproute jemalloc numactl procps-ng less hostname openssl wget && \
    groupadd -f -g 1014 cassandra && adduser -M -g cassandra cassandra && \
    usermod -a -G $CONTRAIL_GID cassandra && \    
    wget -nv --tries=3 -O cassandra-$CASSANDRA_VERSION-bin.tar.gz -c $DIST_URL && \
    mkdir -p ${CASSANDRA_HOME} && \
    tar -xzvf cassandra-$CASSANDRA_VERSION-bin.tar.gz -C ${CASSANDRA_HOME} --strip-components 1 && \
    rm -rf  cassandra-$CASSANDRA_VERSION-bin.tar.gz && \
    mv "$CASSANDRA_HOME/conf" "$CASSANDRA_CONF" && \
	ln -sT "$CASSANDRA_CONF" "$CASSANDRA_HOME/conf" && \
	mkdir -p "$CASSANDRA_CONF" /var/lib/cassandra /var/log/cassandra && \
	chown -R cassandra:cassandra "$CASSANDRA_CONF" /var/lib/cassandra /var/log/cassandra && \
	chmod 777 "$CASSANDRA_CONF" /var/lib/cassandra /var/log/cassandra && \
	ln -sT /var/lib/cassandra "$CASSANDRA_HOME/data" && \
	ln -sT /var/log/cassandra "$CASSANDRA_HOME/logs" && \
	yum clean all -y && \
    rm -rf /var/cache/yum && \
# smoke test
	cassandra -v


VOLUME /var/lib/cassandra
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
