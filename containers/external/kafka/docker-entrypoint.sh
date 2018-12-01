#!/bin/bash

set -e

source /functions.sh

default_ip_address=$(get_default_ip)
local_ips=",$(cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}' | tr '\n' ','),"

CONFIG="$KAFKA_CONF_DIR/server.properties"

CONTROLLER_NODES=${CONTROLLER_NODES:-${default_ip_address}}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}
ANALYTICSDB_NODES=${ANALYTICSDB_NODES:-${ANALYTICS_NODES}}
KAFKA_NODES=${KAFKA_NODES:-${ANALYTICSDB_NODES}}
ZOOKEEPER_ANALYTICS_NODES=${ZOOKEEPER_ANALYTICS_NODES:-${ANALYTICSDB_NODES}}
ZOOKEEPER_ANALYTICS_PORT=${ZOOKEEPER_ANALYTICS_PORT:-2182}
KAFKA_SSL_ENABLE=${KAFKA_SSL_ENABLE:-${SSL_ENABLE:-False}}

: ${KAFKA_LISTEN_ADDRESS='auto'}
my_index=1
if [ "$KAFKA_LISTEN_ADDRESS" = 'auto' ]; then
  # In all in one deployment there is the race between vhost0 initialization
  # and own IP detection, so there is 10 retries
  for i in {1..10} ; do
    my_ip=''
    IFS=',' read -ra server_list <<< "$KAFKA_NODES"
    for server in "${server_list[@]}"; do
      if server_ip=`python -c "import socket; print(socket.gethostbyname('$server'))"` \
          && [[ "$local_ips" =~ ",$server_ip," ]] ; then
        echo "INFO: found '$server/$server_ip' in local IPs '$local_ips'"
        my_ip=$server_ip
        break
      fi
      (( my_index+=1 ))
    done
    if [ -n "$my_ip" ]; then
      break
    fi
    sleep 1
  done

  if [ -z "$my_ip" ]; then
    echo "ERROR: Cannot find self ips ('$local_ips') in Kafka nodes ('$KAFKA_NODES')"
    exit -1
  fi

  export KAFKA_LISTEN_ADDRESS=$my_ip
fi

zk_server_list=''
# zk_chroot_list=''
IFS=',' read -ra server_list <<< "${ZOOKEEPER_ANALYTICS_NODES}"
for server in "${server_list[@]}"; do
  zk_server_list+=${server}:${ZOOKEEPER_ANALYTICS_PORT},
done

zk_list="${zk_server_list::-1}"
if [[ `echo ${#server_list[@]}` -gt 1 ]] ; then
  replication_factor=2
else
  replication_factor=1
fi
KAFKA_BROKER_ID=${my_index:-1}
KAFKA_PORT=${KAFKA_PORT:-9092}
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

sed -i "s/^broker.id=.*$/broker.id=$KAFKA_BROKER_ID/g" ${CONFIG}
sed -i "s/#port=.*$/port=$KAFKA_LISTEN_PORT/g" ${CONFIG}
if [[ ${KAFKA_SSL_ENABLE} == "False" ]] ; then
    sed -i "s/^listeners=.*$/listeners=PLAINTEXT:\/\/$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT/g" ${CONFIG}
else
    export RANDFILE=${KAFKA_DIR}/.rnd
    if [ -e ${KAFKA_DIR}/kafka.server.keystore.jks ] ; then
        ! keytool -list -keystore ${KAFKA_DIR}/kafka.server.keystore.jks \
           -keypass ${KAFKA_KEY_PASSWORD} -storepass ${KAFKA_STORE_PASSWORD} \
           -v | grep -q -i caroot || \
        echo "Deleting existing CARoot cert from store"
        keytool -delete -keystore ${KAFKA_DIR}/kafka.server.keystore.jks \
            -keypass ${KAFKA_KEY_PASSWORD} -storepass ${KAFKA_STORE_PASSWORD} \
            -alias CARoot
        ! keytool -list -keystore ${KAFKA_DIR}/kafka.server.keystore.jks \
            -keypass ${KAFKA_KEY_PASSWORD} -storepass ${KAFKA_STORE_PASSWORD} \
            -v | grep -q -i localhost || \
        echo "Deleting existing localhost cert from store"
        keytool -delete -keystore ${KAFKA_DIR}/kafka.server.keystore.jks \
            -keypass ${KAFKA_KEY_PASSWORD}  -storepass ${KAFKA_STORE_PASSWORD} \
            -alias localhost
    fi
    keytool -keystore ${KAFKA_DIR}/kafka.server.keystore.jks \
            -keypass ${KAFKA_KEY_PASSWORD} -storepass ${KAFKA_STORE_PASSWORD} \
            -noprompt \
            -alias CARoot -import -file /etc/contrail/ssl/certs/ca-cert.pem
    openssl pkcs12 -export -in /etc/contrail/ssl/certs/server.pem \
            -inkey /etc/contrail/ssl/private/server-privkey.pem \
            -chain -CAfile /etc/contrail/ssl/certs/ca-cert.pem \
            -password pass:${KAFKA_KEY_PASSWORD} -name localhost -out TmpFile
    keytool -importkeystore -deststorepass ${KAFKA_KEY_PASSWORD} \
           -destkeystore ${KAFKA_DIR}/kafka.server.keystore.jks \
           -srcstorepass ${KAFKA_STORE_PASSWORD} -srckeystore TmpFile \
           -srcstoretype PKCS12 -alias localhost
    echo "Created keystore"
    sed -i "s/^listeners=.*$/listeners=SSL:\/\/$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT/g" ${CONFIG}
    grep -q '^ssl.keystore.location' ${CONFIG} && sed -i 's/^ssl.keystore.location.*$/ssl.keystore.location=\/var\/private\/ssl\/kafka.server.keystore.jks/' ${CONFIG}  || e
    grep -q '^ssl.truststore' ${CONFIG} && sed -i 's/^ssl.truststore.*$/ssl.truststore=\/var\/private\/ssl\/kafka.server.truststore.jks/' ${CONFIG}  || echo "ssl.truststore
    grep -q '^ssl.keystore.password' ${CONFIG} && sed -i 's/^ssl.keystore.password.*$/ssl.keystore.password=c0ntrail123/' ${CONFIG}  || echo "ssl.keystore.password=c0ntrail
    grep -q '^ssl.key.password' ${CONFIG} && sed -i 's/^ssl.key.password.*$/ssl.key.password=c0ntrail123/' ${CONFIG}  || echo "ssl.key.password=c0ntrail123" >> ${CONFIG}
    grep -q '^ssl.truststore.password' ${CONFIG} && sed -i 's/^ssl.truststore.password.*$/ssl.truststore.password=c0ntrail123/' ${CONFIG}  || echo "ssl.truststore.password=
    grep -q '^security.inter.broker.protocol' ${CONFIG} && sed -i 's/^security.inter.broker.protocol.*$/security.inter.broker.protocol=SSL/' ${CONFIG}  || echo "security.in
fi

sed -i "s)^zookeeper.connect=.*$)zookeeper.connect=$zk_list)g" ${CONFIG}
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
