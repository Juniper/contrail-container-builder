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
if [[ ${KAFKA_SSL_ENABLE} == "False" ]] ; then
    sed -i "s/^listeners=.*$/listeners=PLAINTEXT:\/\/$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT/g" ${CONFIG}
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
    sed -i "s/^listeners=.*$/listeners=SSL:\/\/$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT/g" ${CONFIG}
    (grep -q '^advertised.listeners' ${CONFIG} && sed -i "s|^advertised.listeners.*$|advertised.listeners=SSL://$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT|" ${CONFIG}) || echo "advertised.listeners=SSL://$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT" >> ${CONFIG}
    (grep -q '^ssl.keystore.location' ${CONFIG} && sed -i "s|^ssl.keystore.location.*$|ssl.keystore.location=${KAFKA_DIR}/kafka.server.keystore.jks|" ${CONFIG}) || echo "ssl.keystore.location=${KAFKA_DIR}/kafka.server.keystore.jks" >> ${CONFIG}
    (grep -q '^ssl.truststore.location' ${CONFIG} && sed -i "s|^ssl.truststore.location.*$|ssl.truststore.location=${KAFKA_DIR}/kafka.server.truststore.jks|" ${CONFIG})  || echo "ssl.truststore.location=${KAFKA_DIR}/kafka.server.truststore.jks" >> ${CONFIG}
    (grep -q '^ssl.keystore.password' ${CONFIG} && sed -i "s|^ssl.keystore.password.*$|ssl.keystore.password=${KAFKA_STORE_PASSWORD}|" ${CONFIG}) || echo "ssl.keystore.password=${KAFKA_STORE_PASSWORD}" >> ${CONFIG}
    (grep -q '^ssl.key.password' ${CONFIG} && sed -i "s|^ssl.key.password.*$|ssl.key.password=${KAFKA_KEY_PASSWORD}|" ${CONFIG}) || echo "ssl.key.password=${KAFKA_KEY_PASSWORD}" >> ${CONFIG}
    (grep -q '^ssl.truststore.password' ${CONFIG} && sed -i "s|^ssl.truststore.password.*$|ssl.truststore.password=${KAFKA_STORE_PASSWORD}|" ${CONFIG}) || echo "ssl.truststore.password=${KAFKA_STORE_PASSWORD}" >> ${CONFIG}
    (grep -q '^security.inter.broker.protocol' ${CONFIG} && sed -i 's|^security.inter.broker.protocol.*$|security.inter.broker.protocol=SSL|' ${CONFIG}) || echo "security.inter.broker.protocol=SSL" >> ${CONFIG}
fi

sed -i "s)^zookeeper.connect=.*$)zookeeper.connect=$ZOOKEEPER_ANALYTICS_SERVERS)g" ${CONFIG}
sed -i "s/#advertised.host.name=.*$/advertised.host.name=$my_ip/g" ${CONFIG}
sed -i "s/^#log.retention.bytes=.*$/log.retention.bytes=$KAFKA_log_retention_bytes/g" ${CONFIG}
sed -i "s/^log.retention.hours=.*$/log.retention.hours=$KAFKA_log_retention_hours/g" ${CONFIG}
sed -i "s/^log.segment.bytes=.*$/log.segment.bytes=$KAFKA_log_segment_bytes/g" ${CONFIG}
echo "log.cleanup.policy=${KAFKA_log_cleanup_policy}" >> ${CONFIG}
echo "log.cleaner.threads=${KAFKA_log_cleaner_threads}" >> ${CONFIG}
echo "log.cleaner.dedupe.buffer.size=${KAFKA_log_cleaner_dedupe_buffer_size}" >> ${CONFIG}
sed -i "s/^num.partitions=.*$/num.partitions=30/g" ${CONFIG}
sed -i "s/^default.replication.factor=.*/default.replication.factor=$replication_factor/g" ${CONFIG}
echo "offsets.topic.replication.factor=$replication_factor" >> ${CONFIG}
echo "reserved.broker.max.id=100001" >> ${CONFIG}

exec "$@"
