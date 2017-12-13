#!/bin/bash

set -e

default_interface=`ip route show |grep "default via" |awk '{print $5}'`
default_ip_address=`ip address show dev $default_interface |head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
: ${KAFKA_LISTEN_ADDRESS='auto'}
if [ "$KAFKA_LISTEN_ADDRESS" = 'auto' ]; then
        KAFKA_LISTEN_ADDRESS=${default_ip_address}
fi
CONFIG="$KAFKA_CONF_DIR/server.properties"
CONTROLLER_NODES=${CONTROLLER_NODES:-`hostname`}
ZOOKEEPER_ANALYTICS_NODES=${ZOOKEEPER_ANALYTICS_NODES:-${CONTROLLER_NODES}}
ZOOKEEPER_ANALYTICS_PORT=${ZOOKEEPER_ANALYTICS_PORT:-2182}
zk_server_list=''
server_index=1
IFS=',' read -ra server_list <<< "${ZOOKEEPER_ANALYTICS_NODES}"
for server in "${server_list[@]}"; do
  zk_server_list+=${server}:${ZOOKEEPER_ANALYTICS_PORT},
  if [ ${default_ip_address} == $server ]; then
    my_index=$server_index
  fi
  server_index=$((server_index+1))
done
zk_list="${zk_server_list::-1}"
if [ `echo ${#server_list[@]}` -gt 1 ];then
  replication_factor=2
else
  replication_factor=1
fi
KAFKA_BROKER_ID=${my_index:-1}
KAFKA_log_retention_bytes=${KAFKA_log_retention_bytes:-268435456}
KAFKA_log_segment_bytes=${KAFKA_log_segment_bytes:-268435456}
KAFKA_log_retention_hours=${KAFKA_log_retention_hours:-24}
KAFKA_log_cleanup_policy=${KAFKA_log_cleanup_policy:-delete}
KAFKA_log_cleaner_threads=${KAFKA_log_cleaner_threads:-2}
KAFKA_log_cleaner_dedupe_buffer_size=${KAFKA_log_cleaner_dedupe_buffer_size:-250000000}
KAFKA_log_cleaner_enable=${KAFKA_log_cleaner_enable:-true}
KAFKA_delete_topic_enable=${KAFKA_delete_topic_enable:-true}

sed -i "s/^#log.retention.bytes=.*$/log.retention.bytes=$KAFKA_log_retention_bytes/g" ${CONFIG}
sed -i "s/^log.segment.bytes=.*$/log.retention.bytes=$KAFKA_log_segment_bytes/g" ${CONFIG}
sed -i "s/^log.retention.hours=.*$/log.retention.hours=$KAFKA_log_retention_hours/g" ${CONFIG}
sed -i "s/^zookeeper.connect=.*$/zookeeper.connect=$zk_list/g" ${CONFIG}
sed -i "s/^num.partitions=.*$/num.partitions=30/g" ${CONFIG}
sed -i "s/^num.partitions=.*$/num.partitions=30/g" ${CONFIG}
sed -i "s/^broker.id=.*$/broker.id=$KAFKA_BROKER_ID/g" ${CONFIG}
sed -i "s/^#advertised.host.name=.*$/advertised.host.name=$KAFKA_LISTEN_ADDRESS/g" ${CONFIG}
printf "\ndefault.replication.factor=$replication_factor" >> ${CONFIG}
printf "\nlog.cleanup.policy=${KAFKA_log_cleanup_policy}" >> ${CONFIG}
printf "\nlog.cleaner.threads=${KAFKA_log_cleaner_threads}" >> ${CONFIG}
printf "\nlog.cleaner.dedupe.buffer.size=${KAFKA_log_cleaner_dedupe_buffer_size}" >> ${CONFIG}

exec "$@"
