#!/bin/bash -e

cluster_nodes='{['
local_ips=",$(cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}' | tr '\n' ','),"
IFS=',' read -ra server_list <<< "${RABBITMQ_NODES}"
my_ip=''
my_node=''
rabbit_node_list=''
for server in ${server_list[@]}; do
  server_hostname=''
  if getent hosts $server ; then
    server_hostname=$(getent hosts $server | awk '{print $2}' | awk -F '.' '{print $1}')
  else
    if host -4 $server ; then
      server_hostname=$(host -4 $server | cut -d" " -f5 | awk '{print $1}')
      server_hostname=${server_hostname::-1}
    fi
  fi
  if [[ "$server_hostname" == '' ]] ; then
    echo "WARNING: hostname for $server is not resolved properly, cluster setup will not be functional."
  fi
  cluster_nodes+="'contrail@${server_hostname}',"
  if [[ "$local_ips" =~ ",$server," ]] ; then
    my_ip=$server
    my_node=$server_hostname
    echo "INFO: my_ip=$server my_node=$server_hostname"
  fi
done

cluster_nodes=${cluster_nodes::-1}'],disc}'
if [ -z "$my_ip" ] ; then
  echo "ERROR: Cannot find self ips ('$local_ips') in RabbitMQ nodes ('$RABBITMQ_NODES')"
  exit
fi

export RABBITMQ_NODENAME=contrail@$my_node
if [[ "$RABBITMQ_NODE_PORT" != '' ]] ; then
  export RABBITMQ_NODE_PORT=${RABBITMQ_NODE_PORT}
fi
if (( ${#server_list[@]} > 1 )); then
  export RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="-rabbit cluster_nodes $cluster_nodes"
fi

echo "INFO: RABBITMQ_NODENAME=$RABBITMQ_NODENAME, RABBITMQ_NODE_PORT=$RABBITMQ_NODE_PORT"
echo "INFO: RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS=$RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS"
echo "INFO: /docker-entrypoint.sh $@"

exec /docker-entrypoint.sh "$@"
