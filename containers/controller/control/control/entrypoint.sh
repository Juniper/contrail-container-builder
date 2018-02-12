#!/bin/bash

source /common.sh

hostip=$(get_listen_ip_for_node CONTROL)
hostname=${DEFAULT_HOSTNAME}

rabbitmq_server_list=$(echo $RABBITMQ_SERVERS | sed 's/,/ /g')
configdb_cql_servers=$(echo $CONFIGDB_CQL_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-control.conf << EOM
[DEFAULT]
# bgp_config_file=bgp_config.xml
bgp_port=$BGP_PORT
collectors=$COLLECTOR_SERVERS
# gr_helper_bgp_disable=0
# gr_helper_xmpp_disable=0
hostip=${hostip}
hostname=${hostname}
http_server_port=${CONTROL_INTROSPECT_LISTEN_PORT:-$CONTROL_INTROSPECT_PORT}
log_file=${CONTROL_LOG_FILE:-"$LOG_DIR/contrail-control.log"}
log_level=${CONTROL_LOG_LEVEL:-$LOG_LEVEL}
log_local=${CONTROL_LOG_LOCAL:-$LOG_LOCAL}
# log_files_count=${CONTROL_log_files_count:-10}
# log_file_size=${CONTROL_log_file_size:-10485760} # 10MB
# log_category= ${CONTROL_log_category:-""}
# log_disable= ${CONTROL_log_disable:-0}
xmpp_server_port=$XMPP_SERVER_PORT
xmpp_auth_enable=${XMPP_SSL_ENABLE}
xmpp_server_cert=${XMPP_SERVER_CERT}
xmpp_server_key=${XMPP_SERVER_KEY}
xmpp_ca_cert=${XMPP_SERVER_CA_CERT}

# Sandesh send rate limit can be used to throttle system logs transmitted per
# second. System logs are dropped if the sending rate is exceeded
# sandesh_send_rate_limit=

[CONFIGDB]
# AMQP related configs
rabbitmq_server_list=$rabbitmq_server_list
rabbitmq_vhost=$RABBITMQ_VHOST
rabbitmq_user=$RABBITMQ_USER
rabbitmq_password=$RABBITMQ_PASSWORD
rabbitmq_use_ssl=$RABBITMQ_USE_SSL
# rabbitmq_ssl_version=
# rabbitmq_ssl_keyfile=
# rabbitmq_ssl_certfile=
# rabbitmq_ssl_ca_certs=
#
config_db_server_list=$configdb_cql_servers
# config_db_username=
# config_db_password=

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

wait_for_contrail_api

if [[ "$BGP_AUTO_MESH" == 'true' ]] ; then
  ibgp_auto_mesh_opt='--ibgp_auto_mesh'
else
  ibgp_auto_mesh_opt='--no_ibgp_auto_mesh'
fi

provision_node provision_control.py $hostip $hostname \
  --router_asn ${BGP_ASN} $ibgp_auto_mesh_opt \
  --bgp_server_port ${BGP_PORT}

exec "$@"
