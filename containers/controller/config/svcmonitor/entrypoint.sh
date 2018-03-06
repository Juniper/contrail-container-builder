#!/bin/bash

source /common.sh

cassandra_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-svc-monitor.conf << EOM
[DEFAULTS]
api_server_ip=$CONFIG_API_VIP
api_server_port=$CONFIG_API_PORT
log_file=${CONFIG_SVCMONITOR_LOG_FILE:-"$LOG_DIR/contrail-svc-monitor.log"}
log_level=${CONFIG_SVCMONITOR_LOG_LEVEL:-$LOG_LEVEL}
cassandra_server_list=$cassandra_server_list
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
aaa_mode = $AAA_MODE

$sandesh_client_config
EOM

add_ini_params_from_env SVC_MONITOR /etc/contrail/contrail-svc-monitor.conf

set_third_party_auth_config
set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"
