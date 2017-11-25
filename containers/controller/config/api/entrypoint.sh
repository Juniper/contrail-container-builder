#!/bin/bash

source /common.sh

host_ip=$(get_listen_ip_for_node CONFIG)

cat > /etc/contrail/contrail-api.conf << EOM
[DEFAULTS]
listen_ip_addr=${host_ip}
listen_port=$CONFIG_API_PORT
http_server_port=${CONFIG_API_INTROSPECT_PORT}
log_file=${CONFIG_API_LOG_FILE:-"$LOG_DIR/contrail-api.log"}
log_level=${CONFIG_API_LOG_LEVEL:-$LOG_LEVEL}
list_optimization_enabled=${CONFIG_API_LIST_OPTIMIZATION_ENABLED:-True}
auth=$AUTH_MODE
aaa_mode=$AAA_MODE
cassandra_server_list=$CONFIGDB_SERVERS
zk_server_ip=$ZOOKEEPER_SERVERS
rabbit_server=$RABBITMQ_SERVERS
rabbit_vhost=$RABBITMQ_VHOST
rabbit_user=$RABBITMQ_USER
rabbit_password=$RABBITMQ_PASSWORD
redis_server=$REDIS_SERVER_IP
collectors=$COLLECTOR_SERVERS

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

function wait_and_provision_self() {
  wait_for_contrail_api
  provision_node provision_config_node.py $host_ip $DEFAULT_HOSTNAME
  provision provision_linklocal.py --oper add \
    --linklocal_service_name $LINKLOCAL_SERVICE_NAME \
    --linklocal_service_ip $LINKLOCAL_SERVICE_IP \
    --linklocal_service_port $LINKLOCAL_SERVICE_PORT \
    --ipfabric_service_ip $IPFABRIC_SERVICE_IP \
    --ipfabric_service_port $IPFABRIC_SERVICE_PORT
}

wait_and_provision_self &

exec "$@"
