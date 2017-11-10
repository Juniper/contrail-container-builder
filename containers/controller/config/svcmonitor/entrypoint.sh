#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-svc-monitor.conf << EOM
[DEFAULTS]
api_server_ip=${CONFIG_API_ADDRESS:-`get_listen_ip`}
api_server_port=$CONFIG_API_PORT
log_file=${CONFIG_SVCMONITOR_LOG_FILE:-"$LOG_DIR/contrail-svc-monitor.log"}
log_level=${CONFIG_SVCMONITOR_LOG_LEVEL:-$LOG_LEVEL}
cassandra_server_list=$CONFIGDB_SERVERS
zk_server_ip=$ZOOKEEPER_SERVERS
rabbit_server=$RABBITMQ_SERVERS
rabbit_vhost=$RABBITMQ_VHOST
rabbit_user=$RABBITMQ_USER
rabbit_password=$RABBITMQ_PASSWORD
redis_server=$REDIS_SERVER_IP
collectors=$COLLECTOR_SERVERS

[SECURITY]
#use_certs=False
#keyfile=/etc/contrail/ssl/private_keys/svc_monitor_key.pem
#certfile=/etc/contrail/ssl/certs/svc_monitor.pem
#ca_certs=/etc/contrail/ssl/certs/ca.pem

[SCHEDULER]
# Analytics server list used to get vrouter status and schedule service instance
analytics_server_list=$ANALYTICS_SERVERS
aaa_mode = ${ANALYTICS_API_AAA_MODE:-no-auth}

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
