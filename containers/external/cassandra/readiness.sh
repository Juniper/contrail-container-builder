#!/bin/bash -e

source /common.sh

my_ip=$(find_my_ip_and_order_for_node_list "$CASSANDRA_SEEDS" | cut -d ' ' -f 1)
if [[ -z "$my_ip" ]] ; then
  my_ip=$(get_default_ip)
fi

if ! nodetool status -p "$CASSANDRA_JMX_LOCAL_PORT" | grep -E "^UN\\s+$my_ip"; then
  echo "ERROR: Nodetool status: "
  echo "$(nodetool status -p $CASSANDRA_JMX_LOCAL_PORT)"
  exit 1
fi
