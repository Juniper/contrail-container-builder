#!/bin/bash

set -e
function get_listen_ip(){
  default_interface=`ip route show |grep "default via" |awk '{print $5}'`
  default_ip_address=`ip address show dev $default_interface |\
                    head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
  echo ${default_ip_address}
}

CONFIG="$ZOO_CONF_DIR/zoo.cfg"

echo "clientPort=$ZOO_PORT" >> "$CONFIG"
echo "dataDir=$ZOO_DATA_DIR" >> "$CONFIG"
echo "dataLogDir=$ZOO_DATA_LOG_DIR" >> "$CONFIG"

echo "tickTime=$ZOO_TICK_TIME" >> "$CONFIG"
echo "initLimit=$ZOO_INIT_LIMIT" >> "$CONFIG"
echo "syncLimit=$ZOO_SYNC_LIMIT" >> "$CONFIG"

CONTROLLER_NODES=${CONTROLLER_NODES:-`hostname`}
ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-${CONTROLLER_NODES}}
IFS=',' read -ra server_list <<< "${ZOOKEEPER_NODES}"
server_index=1
for server in "${server_list[@]}"; do
  echo "server.${server_index}=${server}:2888:3888" >> $CONFIG
  if [ `get_listen_ip` == $server ]; then
    my_index=$server_index
  fi
  server_index=$((server_index+1))
done
echo "${my_index:-1}" > "$ZOO_DATA_DIR/myid"

exec "$@"
