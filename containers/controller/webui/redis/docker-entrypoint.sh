#!/bin/bash
set -e
function get_listen_ip(){
  default_interface=`ip route show |grep "default via" |awk '{print $5}'`
  default_ip_address=`ip address show dev $default_interface |\
                    head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
  echo ${default_ip_address}
}
REDIS_PORT=${REDIS_PORT:-6379}
REDIS_BIND_IP=${REDIS_BIND_IP:-`get_listen_ip`}

sed -i "s/^bind.*$/bind 127.0.0.1 ${REDIS_BIND_IP}/g" /etc/redis.conf
sed -i "s/^port.*$/port ${REDIS_PORT}/g" /etc/redis.conf

exec "$@"
