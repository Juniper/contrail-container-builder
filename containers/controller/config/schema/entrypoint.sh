#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-schema.conf << EOM
[DEFAULTS]
api_server_ip=${CONFIG_API_ADDRESS:-`get_listen_ip`}
api_server_port=$CONFIG_API_PORT
log_file=${CONFIG_SCHEMA_LOG_FILE:-"$LOG_DIR/contrail-schema.log"}
log_level=${CONFIG_SCHEMA_LOG_LEVEL:-$LOG_LEVEL}
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

exec "$@"
