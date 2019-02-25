#!/bin/bash

source /common.sh

pre_start_init

host_ip=$(get_listen_ip_for_node ANALYTICS)

cat > /etc/contrail/contrail-json2sandesh.conf << EOM
[INIT_GENERATOR]
instance_id=99
collectors=$COLLECTOR_SERVERS
log_level=$LOG_LEVEL
log_file=$LOG_DIR/contrail-json2sandesh.log
enable_syslog=$LOG_LOCAL
syslog_facility=
sandesh_send_rate_limit=100

[INTERFACE_CONFIG]
api_host=${host_ip}
api_port=8113
api_debug=False
EOM

add_ini_params_from_env ANALYTICS_JSON2SANDESH /etc/contrail/contrail-json2sandesh.conf

exec "$@"
