#!/bin/bash

source /common.sh

pre_start_init

host_ip=$(get_listen_ip_for_node CONFIG)
cassandra_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

mkdir -p /etc/contrail
cat > /etc/contrail/contrail-device-manager.conf << EOM
[DEFAULTS]
host_ip=${host_ip}
http_server_ip=$(get_introspect_listen_ip_for_node CONFIG)
api_server_ip=$CONFIG_NODES
api_server_port=$CONFIG_API_PORT
api_server_use_ssl=${CONFIG_API_SSL_ENABLE}
analytics_server_ip=$ANALYTICS_NODES
analytics_server_port=$ANALYTICS_API_PORT
push_mode=1
log_file=$LOG_DIR/contrail-device-manager.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
cassandra_server_list=$cassandra_server_list
cassandra_use_ssl=${CASSANDRA_SSL_ENABLE,,}
cassandra_ca_certs=$CASSANDRA_SSL_CA_CERTFILE
zk_server_ip=$ZOOKEEPER_SERVERS

# configure directories for job manager
# the same directories must be mounted to dnsmasq and DM container
dnsmasq_conf_dir=/etc/dnsmasq
tftp_dir=/etc/tftp
dhcp_leases_file=/var/lib/dnsmasq/dnsmasq.leases

rabbit_server=$RABBITMQ_SERVERS
$rabbit_config
$kombu_ssl_config

collectors=$COLLECTOR_SERVERS

$sandesh_client_config

$collector_stats_config
EOM

add_ini_params_from_env DEVICE_MANAGER /etc/contrail/contrail-device-manager.conf

cat > /etc/contrail/contrail-fabric-ansible.conf <<EOM
[DEFAULTS]
log_file=$LOG_DIR/contrail-fabric-ansible.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
collectors=$COLLECTOR_SERVERS

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
