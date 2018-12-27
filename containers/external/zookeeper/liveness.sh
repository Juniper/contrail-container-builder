#!/bin/bash -e

source /common.sh

my_ip=$(get_listen_ip_for_node ZOOKEEPER)
OK=$(echo ruok | nc $my_ip $ZOOKEEPER_PORT)
if [ "$OK" == "imok" ]; then
    exit 0
else
    exit 1
fi
