#!/bin/bash -e

cluster_nodes='{['
IFS="," read -ra srv_list <<< "$RABBITMQ_NODES"
local_ips=$(cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}')
for srv in "${srv_list[@]}"; do
  node_name="node-"$(echo $srv | tr '.' '-')
  cluster_nodes+="'rabbit@$node_name',"
  echo $srv $node_name >> /etc/hosts
  if [[ "$local_ips" =~ "$srv" ]] ; then
    echo "INFO: found '$srv' in local IPs '$local_ips'"
    my_ip=$srv
    my_node=$node_name
  fi
done

cluster_nodes=${cluster_nodes::-1}'],disc}'
if [ -z "$my_ip" ]; then
  echo "ERROR: Cannot find self ips ('$local_ips') in RabbitMQ nodes ('$RABBITMQ_NODES')"
  exit
fi

export RABBITMQ_NODENAME=rabbit@$my_node
if (( ${#srv_list[@]} > 1 )); then
  export RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="-rabbit cluster_nodes $cluster_nodes"
fi

exec "$@"