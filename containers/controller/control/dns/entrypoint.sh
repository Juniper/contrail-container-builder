#!/bin/bash

source /common.sh

hostip=$(get_listen_ip_for_node CONTROL)
rabbitmq_server_list=$(echo $RABBITMQ_SERVERS | sed 's/,/ /g')
configdb_cql_servers=$(echo $CONFIGDB_CQL_SERVERS | sed 's/,/ /g')

DNS_NAMED_CONFIG_FILE=${DNS_NAMED_CONFIG_FILE:-'contrail-named.conf'}
DNS_NAMED_CONFIG_DIRECTORY=${DNS_NAMED_CONFIG_DIRECTORY:-'/etc/contrail/dns'}
DNS_RNDC_CONFIG_FILE=${DNS_RNDC_CONFIG_FILE:-'contrail-rndc.conf'}

mkdir -p ${DNS_NAMED_CONFIG_DIRECTORY}

cat > ${DNS_NAMED_CONFIG_DIRECTORY}/${DNS_RNDC_CONFIG_FILE} << EOM
key "rndc-key" {
    algorithm hmac-md5;
    secret "$RNDC_KEY";
};

options {
    default-key "rndc-key";
    default-server 127.0.0.1;
    default-port 8094;
};
EOM

cat > /etc/contrail/contrail-dns.conf << EOM
[DEFAULT]
collectors=$COLLECTOR_SERVERS
named_config_file = ${DNS_NAMED_CONFIG_FILE}
named_config_directory = ${DNS_NAMED_CONFIG_DIRECTORY}
named_log_file = ${DNS_NAMED_LOG_FILE:-"$LOG_DIR/contrail-named.log"}
rndc_config_file = ${DNS_RNDC_CONFIG_FILE}
named_max_cache_size=${DNS_NAMED_MAX_CACHE_SIZE:-32M} # max-cache-size (bytes) per view, can be in K or M
named_max_retransmissions=${DNS_NAMED_MAX_RETRANSMISSIONS:-12}
named_retransmission_interval=${DNS_RETRANSMISSION_INTERVAL:-1000} # msec

hostip=${hostip}
hostname=${DEFAULT_HOSTNAME}
http_server_port=${DNS_INTROSPECT_LISTEN_PORT:-$DNS_INTROSPECT_PORT}
dns_server_port=$DNS_SERVER_PORT
log_file=${DNS_LOG_FILE:-"$LOG_DIR/contrail-dns.log"}
log_level=${DNS_LOG_LEVEL:-$LOG_LEVEL}
log_local=${DNS_LOG_LOCAL:-$LOG_LOCAL}
# log_files_count=${CONTROL_log_files_count:-10}
# log_file_size=${CONTROL_log_file_size:-10485760} # 10MB
# log_category= ${CONTROL_log_category:-""}
# log_disable= ${CONTROL_log_disable:-0}
xmpp_dns_auth_enable=${XMPP_SSL_ENABLE}
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

exec "$@"
