#!/bin/bash
set -e
function get_listen_ip(){
  default_interface=`ip route show |grep "default via" |awk '{print $5}'`
  default_ip_address=`ip address show dev $default_interface |\
                    head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
  echo ${default_ip_address}
}
REDIS_QUERY_PORT=${REDIS_QUERY_PORT:-6381}
REDIS_QUERY_BIND_IP=${REDIS_QUERY_BIND_IP:-`get_listen_ip`}

sed -i "s/^bind.*$/bind 127.0.0.1 ${REDIS_QUERY_BIND_IP}/g" /etc/redis.conf
sed -i "s/^port.*$/port ${REDIS_QUERY_PORT}/g" /etc/redis.conf

exec "$@"
