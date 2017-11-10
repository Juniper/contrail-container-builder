#!/bin/bash

source /common.sh

listen_ip=${CONTROL_LISTEN_IP:-`get_listen_ip`}
hostname=${CONTROL_HOSTNAME:-`hostname`}

cat > /etc/contrail/contrail-control.conf << EOM
[DEFAULT]
# bgp_config_file=bgp_config.xml
bgp_port=$BGP_PORT
collectors=$COLLECTOR_SERVERS
# gr_helper_bgp_disable=0
# gr_helper_xmpp_disable=0
hostip=$listen_ip
hostname=$hostname
http_server_port=${CONTROL_INTROSPECT_LISTEN_PORT:-$CONTROL_INTROSPECT_PORT}
log_file=${CONTROL_LOG_FILE:-"$LOG_DIR/contrail-control.log"}
log_level=${CONTROL_LOG_LEVEL:-$LOG_LEVEL}
log_local=${CONTROL_LOG_LOCAL:-$LOG_LOCAL}
# log_files_count=${CONTROL_log_files_count:-10}
# log_file_size=${CONTROL_log_file_size:-10485760} # 10MB
# log_category= ${CONTROL_log_category:-""}
# log_disable= ${CONTROL_log_disable:-0}
xmpp_server_port=$XMPP_SERVER_PORT
xmpp_auth_enable=${XMPP_AUTH_ENABLE:-False}
# xmpp_server_cert=${CONTROL_xmpp_server_cert:-/etc/contrail/ssl/certs/server.pem}
# xmpp_server_key=${CONTROL_xmpp_server_key:-/etc/contrail/ssl/private/server-privkey.pem}
# xmpp_ca_cert=${CONTROL_xmpp_ca_cert:-/etc/contrail/ssl/certs/ca-cert.pem}

# Sandesh send rate limit can be used to throttle system logs transmitted per
# second. System logs are dropped if the sending rate is exceeded
# sandesh_send_rate_limit=

[CONFIGDB]
# AMQP related configs
rabbitmq_server_list=$RABBITMQ_SERVERS
rabbitmq_vhost=$RABBITMQ_VHOST
rabbitmq_user=$RABBITMQ_USER
rabbitmq_password=$RABBITMQ_PASSWORD
rabbitmq_use_ssl=$RABBITMQ_USE_SSL
# rabbitmq_ssl_version=
# rabbitmq_ssl_keyfile=
# rabbitmq_ssl_certfile=
# rabbitmq_ssl_ca_certs=
#
config_db_server_list=$CONFIGDB_CQL_SERVERS
# config_db_username=
# config_db_password=

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

IFS=',' read -ra config_node_list <<< "${CONFIG_NODES}"
config_node=${config_node_list[0]}
/opt/contrail/utils/provision_control.py --host_name ${hostname} --host_ip ${listen_ip} --router_asn ${BGP_ASN} \
  --api_server_port $CONFIG_API_PORT --oper add --admin_password $ADMIN_PASSWORD --admin_tenant_name $ADMIN_TENANT \
  --admin_user $ADMIN_USER --api_server_ip ${config_node}

exec "$@"
