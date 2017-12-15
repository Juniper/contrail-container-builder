#!/bin/bash

set -e

default_interface=`ip route show |grep "default via" |awk '{print $5}'`
default_ip_address=`ip address show dev $default_interface |head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
local_ips=$(ip addr | awk '/inet/ {print($2)}')

CONFIG="$KAFKA_CONF_DIR/server.properties"
CONFIG_NODES=${CONFIG_NODES:-${default_ip_address}}
ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-${CONFIG_NODES}}
KAFKA_NODES=${KAFKA_NODES:-${ANALYTICSDB_NODES:-${default_ip_address}}}
ZOOKEEPER_ANALYTICS_PORT=${ZOOKEEPER_ANALYTICS_PORT:-2182}

: ${KAFKA_LISTEN_ADDRESS='auto'}
my_index=1
if [ "$KAFKA_LISTEN_ADDRESS" = 'auto' ]; then
  IFS=',' read -ra server_list <<< "$KAFKA_NODES"
  for server in "${server_list[@]}"; do
    if [[ "$local_ips" =~ "$server" ]] ; then
      echo "INFO: found '$server' in local IPs '$local_ips'"
      my_ip=$server
      break
    fi
    (( my_index+=1 ))
  done

  if [ -z "$my_ip" ]; then
    echo "ERROR: Cannot find self ips ('$local_ips') in Cassandra nodes ('$KAFKA_NODES')"
    exit -1
  fi

  export KAFKA_LISTEN_ADDRESS=$my_ip
fi

zk_server_list=''
# zk_chroot_list=''
IFS=',' read -ra server_list <<< "${ZOOKEEPER_NODES}"
for server in "${server_list[@]}"; do
  zk_server_list+=${server}:${ZOOKEEPER_ANALYTICS_PORT},
  # zk_chroot_list+=${server}:${ZOOKEEPER_ANALYTICS_PORT}/kafka-root,
done

# bin/zookeeper-shell.sh "${zk_server_list::-1}" <<< "create /kafka-root []"
# zk_list="${zk_chroot_list::-1}"
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

sed -i "s/^broker.id=.*$/broker.id=$KAFKA_BROKER_ID/g" ${CONFIG}
sed -i "s/#port=.*$/port=$KAFKA_LISTEN_PORT/g" ${CONFIG}
sed -i "s/^listeners=.*$/listeners=PLAINTEXT:\/\/$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT/g" ${CONFIG}
sed -i "s)^zookeeper.connect=.*$)zookeeper.connect=$zk_list)g" ${CONFIG}
sed -i "s/#advertised.host.name=.*$/advertised.host.name=$my_ip/g" ${CONFIG}
sed -i "s/^#log.retention.bytes=.*$/log.retention.bytes=$KAFKA_log_retention_bytes/g" ${CONFIG}
sed -i "s/^log.retention.hours=.*$/log.retention.hours=$KAFKA_log_retention_hours/g" ${CONFIG}
sed -i "s/^log.segment.bytes=.*$/log.segment.bytes=$KAFKA_log_segment_bytes/g" ${CONFIG}
echo "log.cleanup.policy=${KAFKA_log_cleanup_policy}" >> ${CONFIG}
echo "log.cleaner.threads=${KAFKA_log_cleaner_threads}" >> ${CONFIG}
echo "log.cleaner.dedupe.buffer.size=${KAFKA_log_cleaner_dedupe_buffer_size}" >> ${CONFIG}
sed -i "s/^num.partitions=.*$/num.partitions=30/g" ${CONFIG}
echo "default.replication.factor=$replication_factor" >> ${CONFIG}
echo "reserved.broker.max.id: 100001" >> ${CONFIG}

exec "$@"
