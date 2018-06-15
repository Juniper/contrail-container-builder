#!/bin/bash

set -e

source /functions.sh

default_interface=$(get_default_nic)
default_ip_address=$(get_default_ip)
local_ips=",$(cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}' | tr '\n' ','),"

CONFIG="$KAFKA_CONF_DIR/server.properties"

ZOO_START_BIN="$KAFKA_BIN_DIR/zookeeper-server-start"
CONN_STAND_ALONE_BIN="$KAFKA_BIN_DIR/connect-standalone"
CONN_DISTRI_BIN="$KAFKA_BIN_DIR/connect-distributed"
KAFKA_START_BIN="$KAFKA_BIN_DIR/kafka-server-start"
KAFKA_START_BIN_TEST="$KAFKA_BIN_DIR/kafka-server-start_test"

CONTROLLER_NODES=${CONTROLLER_NODES:-${default_ip_address}}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}
ANALYTICSDB_NODES=${ANALYTICSDB_NODES:-${ANALYTICS_NODES}}
KAFKA_NODES=${KAFKA_NODES:-${ANALYTICSDB_NODES}}
ZOOKEEPER_ANALYTICS_NODES=${ZOOKEEPER_ANALYTICS_NODES:-${ANALYTICSDB_NODES}}
ZOOKEEPER_ANALYTICS_PORT=${ZOOKEEPER_ANALYTICS_PORT:-2182}

: ${KAFKA_LISTEN_ADDRESS='auto'}
my_index=1
if [ "$KAFKA_LISTEN_ADDRESS" = 'auto' ]; then
  # In all in one deployment there is the race between vhost0 initialization
  # and own IP detection, so there is 10 retries
  for i in {1..10} ; do
    my_ip=''
    IFS=',' read -ra server_list <<< "$KAFKA_NODES"
    for server in "${server_list[@]}"; do
      if [[ "$local_ips" =~ ",$server," ]] ; then
        echo "INFO: found '$server' in local IPs '$local_ips'"
        my_ip=$server
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

sed -i "s/=\"\$base_dir\/..\/etc/=\"\$base_dir\/..\/..\/etc/g" ${ZOO_START_BIN}
sed -i "s/=\"\$base_dir\/..\/etc/=\"\$base_dir\/..\/..\/etc/g" ${CONN_STAND_ALONE_BIN}
sed -i "s/=\"\$base_dir\/..\/etc/=\"\$base_dir\/..\/..\/etc/g" ${CONN_DISTRI_BIN}
sed -i "s/=\"\$base_dir\/..\/etc/=\"\$base_dir\/..\/..\/etc/g" ${KAFKA_START_BIN}

sed -i "s/^broker.id=.*$/broker.id=$KAFKA_BROKER_ID/g" ${CONFIG}
sed -i "s/#port=.*$/port=$KAFKA_LISTEN_PORT/g" ${CONFIG}
sed -i "s/^listeners=.*$/listeners=PLAINTEXT:\/\/$KAFKA_LISTEN_ADDRESS:$KAFKA_LISTEN_PORT/g" ${CONFIG}
sed -i "s)^zookeeper.connect=.*$)zookeeper.connect=$zk_list)g" ${CONFIG}
sed -i "s/#advertised.host.name=.*$/advertised.host.name=$my_ip/g" ${CONFIG}
sed -i "s/^#log.retention.bytes=.*$/log.retention.bytes=$KAFKA_log_retention_bytes/g" ${CONFIG}
sed -i "s/^log.retention.hours=.*$/log.retention.hours=$KAFKA_log_retention_hours/g" ${CONFIG}
sed -i "s/^log.segment.bytes=.*$/log.segment.bytes=$KAFKA_log_segment_bytes/g" ${CONFIG}
sed -i "s/^num.partitions=.*$/num.partitions=30/g" ${CONFIG}
sed -i "s/^default.replication.factor=.*/default.replication.factor=$replication_factor/g" ${CONFIG}
sed -i "s/group.initial.rebalance.delay.ms=.*$/group.initial.rebalance.delay.ms=20000/g" ${CONFIG}

echo "############################################# "
echo "log.cleaner.threads=${KAFKA_log_cleaner_threads}" >> ${CONFIG}
echo "log.cleaner.dedupe.buffer.size=${KAFKA_log_cleaner_dedupe_buffer_size}" >> ${CONFIG}
echo "offsets.topic.replication.factor=$replication_factor" >> ${CONFIG}
echo "reserved.broker.max.id: 100001" >> ${CONFIG}


exec "$@"
