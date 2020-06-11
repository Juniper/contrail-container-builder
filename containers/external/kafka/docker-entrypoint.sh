#!/bin/bash

set -e

source /common.sh

: ${KAFKA_LISTEN_ADDRESS='auto'}
my_ip=''
my_index=1
if [ "$KAFKA_LISTEN_ADDRESS" = 'auto' ]; then
  # In all in one deployment there is the race between vhost0 initialization
  # and own IP detection, so there is 10 retries
  for i in {1..10} ; do
    my_ip_and_order=$(find_my_ip_and_order_for_node KAFKA)
    if [ -n "$my_ip_and_order" ]; then
      break
    fi
    sleep 1
  done
  if [ -z "$my_ip_and_order" ]; then
    echo "ERROR: Cannot find self ips ('$(get_local_ips)') in Kafka nodes ('$KAFKA_NODES')"
    exit -1
  fi
  my_ip=$(echo $my_ip_and_order | cut -d ' ' -f 1)
  my_index=$(echo $my_ip_and_order | cut -d ' ' -f 2)

  export KAFKA_LISTEN_ADDRESS=$my_ip
fi

zk_servers_array=( $ZOOKEEPER_SERVERS_SPACE_DELIM )
if [[ `echo ${#zk_servers_array[@]}` -gt 1 ]] ; then
  replication_factor=2
else
  replication_factor=1
fi
KAFKA_BROKER_ID=${my_index:-1}
KAFKA_LISTEN_PORT=${KAFKA_LISTEN_PORT:-$KAFKA_PORT}
KAFKA_log_retention_bytes=${KAFKA_log_retention_bytes:-268435456}
KAFKA_log_segment_bytes=${KAFKA_log_segment_bytes:-268435456}
KAFKA_log_retention_hours=${KAFKA_log_retention_hours:-24}
KAFKA_log_cleanup_policy=${KAFKA_log_cleanup_policy:-delete}
KAFKA_log_cleaner_threads=${KAFKA_log_cleaner_threads:-2}
KAFKA_log_cleaner_dedupe_buffer_size=${KAFKA_log_cleaner_dedupe_buffer_size:-250000000}
KAFKA_log_cleaner_enable=${KAFKA_log_cleaner_enable:-true}
KAFKA_delete_topic_enable=${KAFKA_delete_topic_enable:-true}
KAFKA_KEY_PASSWORD=${KAFKA_KEY_PASSWORD:-c0ntrail123}
KAFKA_STORE_PASSWORD=${KAFKA_STORE_PASSWORD:-c0ntrail123}

CONFIG="$KAFKA_CONF_DIR/server.properties"
sed -i "s/^broker.id=.*$/broker.id=$KAFKA_BROKER_ID/g" ${CONFIG}
sed -i "s/#port=.*$/port=$KAFKA_LISTEN_PORT/g" ${CONFIG}
if ! is_enabled ${KAFKA_SSL_ENABLE} ; then
    sed -i "s/^#listeners=.*$/listeners=PLAINTEXT:\/\/$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT/g" ${CONFIG}
else
    export RANDFILE=${KAFKA_DIR}/.rnd
    if [ -e ${KAFKA_DIR}/kafka.server.keystore.jks ] ; then
      rm -f ${KAFKA_DIR}/kafka.server.keystore.jks
    fi
    if [ -e ${KAFKA_DIR}/kafka.server.truststore.jks ] ; then
      rm -f ${KAFKA_DIR}/kafka.server.truststore.jks
    fi
    keytool -keystore ${KAFKA_DIR}/kafka.server.truststore.jks \
            -keypass ${KAFKA_KEY_PASSWORD} -storepass ${KAFKA_STORE_PASSWORD} \
            -noprompt \
            -alias CARoot -import -file ${KAFKA_SSL_CACERTFILE}
    openssl pkcs12 -export -in ${KAFKA_SSL_CERTFILE} \
            -inkey ${KAFKA_SSL_KEYFILE} \
            -chain -CAfile ${KAFKA_SSL_CACERTFILE} \
            -password pass:${KAFKA_KEY_PASSWORD} -name localhost -out TmpFile
    keytool -importkeystore -deststorepass ${KAFKA_KEY_PASSWORD} \
            -destkeystore ${KAFKA_DIR}/kafka.server.keystore.jks \
            -srcstorepass ${KAFKA_STORE_PASSWORD} -srckeystore TmpFile \
            -srcstoretype PKCS12 -alias localhost
    keytool -keystore ${KAFKA_DIR}/kafka.server.keystore.jks \
            -keypass ${KAFKA_KEY_PASSWORD} -storepass ${KAFKA_STORE_PASSWORD} \
            -noprompt \
            -alias CARoot -import -file ${KAFKA_SSL_CACERTFILE}
    echo "Created keystore"
    sed -i "s/^#listeners=.*$/listeners=SSL:\/\/$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT/g" ${CONFIG}
    (grep -q '^advertised.listeners' ${CONFIG} && sed -i "s|^advertised.listeners.*$|advertised.listeners=SSL://$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT|" ${CONFIG}) || echo -e "\nadvertised.listeners=SSL://$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT" >> ${CONFIG}
    (grep -q '^ssl.keystore.location' ${CONFIG} && sed -i "s|^ssl.keystore.location.*$|ssl.keystore.location=${KAFKA_DIR}/kafka.server.keystore.jks|" ${CONFIG}) || echo "ssl.keystore.location=${KAFKA_DIR}/kafka.server.keystore.jks" >> ${CONFIG}
    (grep -q '^ssl.truststore.location' ${CONFIG} && sed -i "s|^ssl.truststore.location.*$|ssl.truststore.location=${KAFKA_DIR}/kafka.server.truststore.jks|" ${CONFIG})  || echo "ssl.truststore.location=${KAFKA_DIR}/kafka.server.truststore.jks" >> ${CONFIG}
    (grep -q '^ssl.keystore.password' ${CONFIG} && sed -i "s|^ssl.keystore.password.*$|ssl.keystore.password=${KAFKA_STORE_PASSWORD}|" ${CONFIG}) || echo "ssl.keystore.password=${KAFKA_STORE_PASSWORD}" >> ${CONFIG}
    (grep -q '^ssl.key.password' ${CONFIG} && sed -i "s|^ssl.key.password.*$|ssl.key.password=${KAFKA_KEY_PASSWORD}|" ${CONFIG}) || echo "ssl.key.password=${KAFKA_KEY_PASSWORD}" >> ${CONFIG}
    (grep -q '^ssl.truststore.password' ${CONFIG} && sed -i "s|^ssl.truststore.password.*$|ssl.truststore.password=${KAFKA_STORE_PASSWORD}|" ${CONFIG}) || echo "ssl.truststore.password=${KAFKA_STORE_PASSWORD}" >> ${CONFIG}
    (grep -q '^security.inter.broker.protocol' ${CONFIG} && sed -i 's|^security.inter.broker.protocol.*$|security.inter.broker.protocol=SSL|' ${CONFIG}) || echo "security.inter.broker.protocol=SSL" >> ${CONFIG}
    (grep -q '^ssl.endpoint.identification.algorithm' ${CONFIG} && sed -i 's|^ssl.endpoint.identification.algorithm.*$|ssl.endpoint.identification.algorithm=|' ${CONFIG}) || echo "ssl.endpoint.identification.algorithm=" >> ${CONFIG} 
fi

sed -i "s)^zookeeper.connect=.*$)zookeeper.connect=$ZOOKEEPER_SERVERS)g" ${CONFIG}
sed -i "s/#advertised.host.name=.*$/advertised.host.name=$my_ip/g" ${CONFIG}
sed -i "s/^#log.retention.bytes=.*$/log.retention.bytes=$KAFKA_log_retention_bytes/g" ${CONFIG}
sed -i "s/^log.retention.hours=.*$/log.retention.hours=$KAFKA_log_retention_hours/g" ${CONFIG}
sed -i "s/^log.segment.bytes=.*$/log.segment.bytes=$KAFKA_log_segment_bytes/g" ${CONFIG}
sed -i "s/^num.partitions=.*$/num.partitions=30/g" ${CONFIG}
sed -i "s/^default.replication.factor=.*/default.replication.factor=$replication_factor/g" ${CONFIG}
echo " " >> ${CONFIG}
echo "log.cleanup.policy=${KAFKA_log_cleanup_policy}" >> ${CONFIG}
echo "log.cleaner.threads=${KAFKA_log_cleaner_threads}" >> ${CONFIG}
echo "log.cleaner.dedupe.buffer.size=${KAFKA_log_cleaner_dedupe_buffer_size}" >> ${CONFIG}
echo "offsets.topic.replication.factor=$replication_factor" >> ${CONFIG}
echo "reserved.broker.max.id=100001" >> ${CONFIG}

if is_enabled $ZOOKEEPER_SSL_ENABLE ; then
  zoo_dir='/usr/local/lib/zookeeper/jks'
  mkdir -p $zoo_dir

  keytool -keystore ${zoo_dir}/zookeeper.server.truststore.jks \
          -keypass ${ZOOKEEPER_SSL_KEY_PASSWORD} 
          -storepass ${ZOOKEEPER_SSL_STORE_PASSWORD} \
          -noprompt \
          -alias CARoot -import -file ${ZOOKEEPER_SSL_CACERTFILE}
  openssl pkcs12 -export -in ${ZOOKEEPER_SSL_CERTFILE} \
          -inkey ${ZOOKEEPER_SSL_KEYFILE} \
          -chain -CAfile ${ZOOKEEPER_SSL_CACERTFILE} \
          -password pass:${ZOOKEEPER_SSL_KEY_PASSWORD}  -name localhost -out TmpFile
  keytool -importkeystore -deststorepass ${ZOOKEEPER_SSL_KEY_PASSWORD} \
          -destkeystore ${zoo_dir}/zookeeper.server.keystore.jks \
          -srcstorepass ${ZOOKEEPER_SSL_STORE_PASSWORD} -srckeystore TmpFile \
          -srcstoretype PKCS12 -alias localhost
  keytool -keystore ${zoo_dir}/zookeeper.server.keystore.jks \
          -keypass ${ZOOKEEPER_SSL_KEY_PASSWORD} 
          -storepass ${ZOOKEEPER_SSL_STORE_PASSWORD} \
          -noprompt \
          -alias CARoot -import -file ${ZOOKEEPER_SSL_CACERTFILE}

  export KAFKA_OPTS="
    -Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty
    -Dzookeeper.client.secure=true
    -Dzookeeper.ssl.keyStore.location=${zoo_dir}/zookeeper.server.keystore.jks
    -Dzookeeper.ssl.keyStore.password=${ZOOKEEPER_SSL_KEY_PASSWORD}
    -Dzookeeper.ssl.trustStore.location=${zoo_dir}/zookeeper.server.truststore.jks
    -Dzookeeper.ssl.trustStore.password=${ZOOKEEPER_SSL_STORE_PASSWORD} 
    "
fi

# Container is run under root, so
# here it is needed to upgrade owner for kafka files
chown -R $KAFKA_USER:$KAFKA_GROUP "$KAFKA_DIR" "$KAFKA_CONF_DIR" "$LOG_DIR"

# replace CONTRAIL_UID and CONTRAIL_GID with kafka values, as they are
# to be used in run_services
CONTRAIL_UID=$(id -u $KAFKA_USER)
CONTRAIL_GID=$(id -g $KAFKA_GROUP)

do_run_service "$@"
