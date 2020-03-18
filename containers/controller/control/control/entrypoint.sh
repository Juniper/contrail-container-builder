#!/bin/bash

source /common.sh

pre_start_init

hostip=$(get_listen_ip_for_node CONTROL)
ip_hostname=$(resolve_hostname_by_ip $hostip)
hostname=${CONTROL_HOSTNAME:-${ip_hostname:-$(get_default_hostname)}}

rabbitmq_server_list=$(echo $RABBITMQ_SERVERS | sed 's/,/ /g')
configdb_cql_servers=$(echo $CONFIGDB_CQL_SERVERS | sed 's/,/ /g')

mkdir -p /etc/contrail
cat > /etc/contrail/contrail-control.conf << EOM
[DEFAULT]
# bgp_config_file=bgp_config.xml
bgp_port=$BGP_PORT
collectors=$COLLECTOR_SERVERS
# gr_helper_bgp_disable=0
# gr_helper_xmpp_disable=0
hostip=${hostip}
hostname=${hostname}
http_server_ip=$(get_introspect_listen_ip_for_node CONTROL)
http_server_port=${CONTROL_INTROSPECT_LISTEN_PORT:-$CONTROL_INTROSPECT_PORT}
log_file=$LOG_DIR/contrail-control.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
# log_files_count=${CONTROL__DEFAULT__log_files_count:-10}
# log_file_size=${CONTROL__DEFAULT__log_file_size:-10485760} # 10MB
# log_category=${CONTROL__DEFAULT__log_category:-""}
# log_disable=${CONTROL__DEFAULT__log_disable:-0}

xmpp_server_port=$XMPP_SERVER_PORT
xmpp_auth_enable=${XMPP_SSL_ENABLE}
$xmpp_certs_config

# Sandesh send rate limit can be used to throttle system logs transmitted per
# second. System logs are dropped if the sending rate is exceeded
# sandesh_send_rate_limit=

[CONFIGDB]
config_db_server_list=$configdb_cql_servers
# config_db_username=
# config_db_password=
config_db_use_ssl=${CASSANDRA_SSL_ENABLE,,}
config_db_ca_certs=$CASSANDRA_SSL_CA_CERTFILE

rabbitmq_server_list=$rabbitmq_server_list
$rabbitmq_config
$rabbitmq_ssl_config

$sandesh_client_config

$collector_stats_config
EOM

add_ini_params_from_env CONTROL /etc/contrail/contrail-control.conf

set_third_party_auth_config
set_vnc_api_lib_ini

run_service "$@"
