#!/bin/bash

# Logging
LOG_LEVEL=${LOG_LEVEL:-SYS_NOTICE}
LOG_DIR=${LOG_DIR:-"/var/log/contrail"}
export CONTAINER_LOG_DIR=${CONTAINER_LOG_DIR:-${LOG_DIR}/${NODE_TYPE}-${SERVICE_NAME}}

LOG_LOCAL=${LOG_LOCAL:-1}

if [[ "${LOG_LEVEL}" == "SYS_DEBUG" ]] ; then
  set -x
fi

source /functions.sh
source /contrail-functions.sh

# Host
DEFAULT_LOCAL_IP=$(get_default_ip)
ENCAP_PRIORITY=${ENCAP_PRIORITY:-'MPLSoUDP,MPLSoGRE,VXLAN'}
VXLAN_VN_ID_MODE=${VXLAN_VN_ID_MODE:-'automatic'}
DPDK_UIO_DRIVER=${DPDK_UIO_DRIVER-'uio_pci_generic'}
CPU_CORE_MASK=${CPU_CORE_MASK:-'0x01'}
SERVICE_CORE_MASK=${SERVICE_CORE_MASK:-}
DPDK_CTRL_THREAD_MASK=${DPDK_CTRL_THREAD_MASK:-}
HUGE_PAGES=${HUGE_PAGES:-""}
HUGE_PAGES_DIR=${HUGE_PAGES_DIR:-'/dev/hugepages'}
HUGE_PAGES_1GB=${HUGE_PAGES_1GB:-0}
HUGE_PAGES_2MB=${HUGE_PAGES_2MB:-0}
HUGE_PAGES_1GB_DIR=${HUGE_PAGES_1GB_DIR:-""}
HUGE_PAGES_2MB_DIR=${HUGE_PAGES_2MB_DIR:-""}
if [[ 0 != $HUGE_PAGES_1GB && -z "$HUGE_PAGES_1GB_DIR" ]] ;then
  HUGE_PAGES_1GB_DIR=$(mount -t hugetlbfs | awk '/pagesize=1G|pagesize=1024M/{print($3)}' | tail -n 1)
fi
if [[ 0 != $HUGE_PAGES_2MB && -z "$HUGE_PAGES_2MB_DIR" ]] ;then
  HUGE_PAGES_2MB_DIR=$(mount -t hugetlbfs | awk '/pagesize=2M/{print($3)}' | tail -n 1)
fi

DPDK_MEM_PER_SOCKET=${DPDK_MEM_PER_SOCKET:-1024}
DPDK_COMMAND_ADDITIONAL_ARGS=${DPDK_COMMAND_ADDITIONAL_ARGS:-}
NIC_OFFLOAD_ENABLE=${NIC_OFFLOAD_ENABLE:-False}
# Protocol with port range or port count can be used DIST_SNAT_PROTO_PORT_LIST=${DIST_SNAT_PROTO_PORT_LIST:-tcp:200,udp:2000-3000,tcp:5000-6000,tcp:1000}
DIST_SNAT_PROTO_PORT_LIST=${DIST_SNAT_PROTO_PORT_LIST:-""}

# Cloud orchestrator
CLOUD_ORCHESTRATOR=${CLOUD_ORCHESTRATOR:-none}
CLOUD_ADMIN_ROLE=${CLOUD_ADMIN_ROLE:-admin}

# Authentication
AAA_MODE=${AAA_MODE:-'no-auth'}
AUTH_MODE=${AUTH_MODE:-'noauth'}
AUTH_PARAMS=''

# Server SSL
SSL_ENABLE=${SSL_ENABLE:-False}
SSL_INSECURE=${SSL_INSECURE:-True}
SERVER_CERTFILE=${SERVER_CERTFILE:-'/etc/contrail/ssl/certs/server.pem'}
SERVER_KEYFILE=${SERVER_KEYFILE:-'/etc/contrail/ssl/private/server-privkey.pem'}
SERVER_CA_CERTFILE=${SERVER_CA_CERTFILE-'/etc/contrail/ssl/certs/ca-cert.pem'}
SERVER_CA_KEYFILE=${SERVER_CA_KEYFILE-'/etc/contrail/ssl/private/ca-key.pem'}
# Set this to True to enable adding all local IP-s to self-signed certs
# that are created by certs-init.sh
SELFSIGNED_CERTS_WITH_IPS=${SELFSIGNED_CERTS_WITH_IPS:-True}

# Controller
CONTROLLER_NODES=${CONTROLLER_NODES:-${DEFAULT_LOCAL_IP}}

# Analytics
ANALYTICS_ALARM_ENABLE=${ANALYTICS_ALARM_ENABLE:-False}
ANALYTICS_SNMP_ENABLE=${ANALYTICS_SNMP_ENABLE:-False}
ANALYTICSDB_ENABLE=${ANALYTICSDB_ENABLE:-False}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}
ANALYTICSDB_NODES=${ANALYTICSDB_NODES:-${ANALYTICS_NODES}}
ANALYTICS_SNMP_NODES=${ANALYTICS_SNMP_NODES:-${ANALYTICS_NODES}}
ANALYTICS_API_PORT=${ANALYTICS_API_PORT:-8081}
ANALYTICS_API_INTROSPECT_PORT=${ANALYTICS_API_INTROSPECT_PORT:-8090}
ANALYTICSDB_PORT=${ANALYTICSDB_PORT:-9160}
ANALYTICSDB_CQL_PORT=${ANALYTICSDB_CQL_PORT:-9042}
TOPOLOGY_INTROSPECT_PORT=${TOPOLOGY_INTROSPECT_PORT:-5921}
QUERYENGINE_INTROSPECT_PORT=${QUERYENGINE_INTROSPECT_PORT:-8091}
ANALYTICS_SERVERS=${ANALYTICS_SERVERS:-`get_server_list ANALYTICS ":$ANALYTICS_API_PORT "`}
ANALYTICSDB_CQL_SERVERS=${ANALYTICSDB_CQL_SERVERS:-`get_server_list ANALYTICSDB ":$ANALYTICSDB_CQL_PORT "`}
ANALYTICS_API_VIP=${ANALYTICS_API_VIP}

# Alarm generator
ANALYTICS_ALARM_NODES=${ANALYTICS_ALARM_NODES:-${ANALYTICS_NODES}}
ALARMGEN_INTROSPECT_PORT=${ALARMGEN_INTROSPECT_PORT:-5995}

# BGP
BGP_PORT=${BGP_PORT:-179}
BGP_AUTO_MESH=${BGP_AUTO_MESH:-'true'}
BGP_ASN=${BGP_ASN:-64512}
ENABLE_4BYTE_AS=${ENABLE_4BYTE_AS:-'false'}

# If set to true - run provisioner.sh in provisioner container
APPLY_DEFAULTS=${APPLY_DEFAULTS:-"true"}

# Collector
COLLECTOR_PORT=${COLLECTOR_PORT:-8086}
COLLECTOR_INTROSPECT_PORT=${COLLECTOR_INTROSPECT_PORT:-8089}
COLLECTOR_SYSLOG_PORT=${COLLECTOR_SYSLOG_PORT:-514}
COLLECTOR_SFLOW_PORT=${COLLECTOR_SFLOW_PORT:-6343}
COLLECTOR_IPFIX_PORT=${COLLECTOR_IPFIX_PORT:-4739}
COLLECTOR_PROTOBUF_PORT=${COLLECTOR_PROTOBUF_PORT:-3333}
COLLECTOR_STRUCTURED_SYSLOG_PORT=${COLLECTOR_STRUCTURED_SYSLOG_PORT:-3514}
SNMPCOLLECTOR_INTROSPECT_PORT=${SNMPCOLLECTOR_INTROSPECT_PORT:-5920}
COLLECTOR_SERVERS=${COLLECTOR_SERVERS:-`get_server_list ANALYTICS ":$COLLECTOR_PORT "`}

# Config
CASSANDRA_PORT=${CASSANDRA_PORT:-9160}
CASSANDRA_CQL_PORT=${CASSANDRA_CQL_PORT:-9042}
CASSANDRA_SSL_STORAGE_PORT=${CASSANDRA_SSL_STORAGE_PORT:-7011}
CASSANDRA_STORAGE_PORT=${CASSANDRA_STORAGE_PORT:-7010}
CASSANDRA_JMX_LOCAL_PORT=${CASSANDRA_JMX_LOCAL_PORT:-7200}
CONFIG_NODES=${CONFIG_NODES:-${CONTROLLER_NODES}}
CONFIGDB_NODES=${CONFIGDB_NODES:-${CONFIG_NODES}}
CONFIG_API_PORT=${CONFIG_API_PORT:-8082}
CONFIG_API_INTROSPECT_PORT=${CONFIG_API_INTROSPECT_PORT:-8084}
CONFIGDB_PORT=${CONFIGDB_PORT:-9161}
CONFIGDB_CQL_PORT=${CONFIGDB_CQL_PORT:-9041}
CONFIG_SERVERS=${CONFIG_SERVERS:-`get_server_list CONFIG ":$CONFIG_API_PORT "`}
CONFIGDB_SERVERS=${CONFIGDB_SERVERS:-`get_server_list CONFIGDB ":$CONFIGDB_PORT "`}
CONFIGDB_CQL_SERVERS=${CONFIGDB_CQL_SERVERS:-`get_server_list CONFIGDB ":$CONFIGDB_CQL_PORT "`}
CONFIG_API_VIP=${CONFIG_API_VIP}
CONFIG_API_SSL_ENABLE=${CONFIG_API_SSL_ENABLE:-${SSL_ENABLE}}
CONFIG_API_SERVER_CERTFILE=${CONFIG_API_SERVER_CERTFILE:-${SERVER_CERTFILE}}
CONFIG_API_SERVER_KEYFILE=${CONFIG_API_SERVER_KEYFILE:-${SERVER_KEYFILE}}
CONFIG_API_SERVER_CA_CERTFILE=${CONFIG_API_SERVER_CA_CERTFILE-${SERVER_CA_CERTFILE}}
ANALYTICS_API_SSL_ENABLE=${ANALYTICS_API_SSL_ENABLE:-${SSL_ENABLE}}
ANALYTICS_API_SSL_INSECURE=${ANALYTICS_API_SSL_INSECURE:-${SSL_INSECURE}}
ANALYTICS_API_SERVER_CERTFILE=${ANALYTICS_API_SERVER_CERTFILE:-${SERVER_CERTFILE}}
ANALYTICS_API_SERVER_KEYFILE=${ANALYTICS_API_SERVER_KEYFILE:-${SERVER_KEYFILE}}
ANALYTICS_API_SERVER_CA_CERTFILE=${ANALYTICS_API_SERVER_CA_CERTFILE:-${SERVER_CA_CERTFILE}}
CASSANDRA_SSL_ENABLE=${CASSANDRA_SSL_ENABLE:-false}
CASSANDRA_SSL_CERTFILE=${CASSANDRA_SSL_CERTFILE:-${SERVER_CERTFILE}}
CASSANDRA_SSL_KEYFILE=${CASSANDRA_SSL_KEYFILE:-${SERVER_KEYFILE}}
CASSANDRA_SSL_CA_CERTFILE=${CASSANDRA_SSL_CA_CERTFILE:-${SERVER_CA_CERTFILE}}
CASSANDRA_SSL_KEYSTORE_PASSWORD=${CASSANDRA_SSL_KEYSTORE_PASSWORD:-'astrophytum'}
CASSANDRA_SSL_TRUSTSTORE_PASSWORD=${CASSANDRA_SSL_TRUSTSTORE_PASSWORD:-'ornatum'}
CASSANDRA_SSL_PROTOCOL=${CASSANDRA_SSL_PROTOCOL:-'TLS'}
CASSANDRA_SSL_ALGORITHM=${CASSANDRA_SSL_ALGORITHM:-'SunX509'}
CASSANDRA_SSL_CIPHER_SUITES=${CASSANDRA_SSL_CIPHER_SUITES:-"[TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]"}
CASSANDRA_CONFIG_MEMTABLE_FLUSH_WRITER=${CASSANDRA_CONFIG_MEMTABLE_FLUSH_WRITER:-4}
CASSANDRA_CONFIG_CONCURRECT_COMPACTORS=${CASSANDRA_CONFIG_CONCURRECT_COMPACTORS:-4}
CASSANDRA_CONFIG_COMPACTION_THROUGHPUT_MB_PER_SEC=${CASSANDRA_CONFIG_COMPACTION_THROUGHPUT_MB_PER_SEC:-256}
CASSANDRA_CONFIG_CONCURRECT_READS=${CASSANDRA_CONFIG_CONCURRECT_READS:-64}
CASSANDRA_CONFIG_CONCURRECT_WRITES=${CASSANDRA_CONFIG_CONCURRECT_WRITES:-64}
CASSANDRA_CONFIG_MEMTABLE_ALLOCATION_TYPE=${CASSANDRA_CONFIG_MEMTABLE_ALLOCATION_TYPE:-offheap_objects}

# Control
CONTROL_NODES=${CONTROL_NODES:-${CONFIG_NODES}}
CONTROL_INTROSPECT_PORT=${CONTROL_INTROSPECT_PORT:-8083}

# DNS
DNS_NODES=${DNS_NODES:-${CONTROL_NODES}}
DNS_SERVER_PORT=${DNS_SERVER_PORT:-53}
DNS_INTROSPECT_PORT=${DNS_INTROSPECT_PORT:-8092}
RNDC_KEY=${RNDC_KEY:-"xvysmOR8lnUQRBcunkC6vg=="}

# DNSmasq
USE_EXTERNAL_TFTP=${USE_EXTERNAL_TFTP:-False}

# Zookeeper
ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-${CONFIGDB_NODES}}
ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
ZOOKEEPER_PORTS=${ZOOKEEPER_PORTS:-2888:3888}
ZOOKEEPER_SERVERS=${ZOOKEEPER_SERVERS:-`get_server_list ZOOKEEPER ":$ZOOKEEPER_PORT,"`}
ZOOKEEPER_SERVERS_SPACE_DELIM=${ZOOKEEPER_SERVERS_SPACE_DELIM:-`get_server_list ZOOKEEPER ":$ZOOKEEPER_PORT "`}

# RabbitMQ
RABBITMQ_NODES=${RABBITMQ_NODES:-${CONFIGDB_NODES}}
RABBITMQ_NODE_PORT=${RABBITMQ_NODE_PORT:-5673}
RABBITMQ_SERVERS=${RABBITMQ_SERVERS:-`get_server_list RABBITMQ ":$RABBITMQ_NODE_PORT,"`}
# RabbitMQ container options. RABBITMQ_USE_SSL must be true to enable SSL for container.
RABBITMQ_SSL_CERTFILE=${RABBITMQ_SSL_CERTFILE:-${SERVER_CERTFILE}}
RABBITMQ_SSL_KEYFILE=${RABBITMQ_SSL_KEYFILE:-${SERVER_KEYFILE}}
RABBITMQ_SSL_CACERTFILE=${RABBITMQ_SSL_CACERTFILE-${SERVER_CA_CERTFILE}}
RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT=${RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT:-true}
# AMQP client options
RABBITMQ_VHOST=${RABBITMQ_VHOST:-/}
RABBITMQ_USER=${RABBITMQ_USER:-guest}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD:-guest}
RABBITMQ_USE_SSL=${RABBITMQ_USE_SSL:-False}
RABBITMQ_SSL_VER=${RABBITMQ_SSL_VER:-'tlsv1.2'}
RABBITMQ_CLIENT_SSL_CERTFILE=${RABBITMQ_CLIENT_SSL_CERTFILE:-${RABBITMQ_SSL_CERTFILE}}
RABBITMQ_CLIENT_SSL_KEYFILE=${RABBITMQ_CLIENT_SSL_KEYFILE:-${RABBITMQ_SSL_KEYFILE}}
RABBITMQ_CLIENT_SSL_CACERTFILE=${RABBITMQ_CLIENT_SSL_CACERTFILE-${RABBITMQ_SSL_CACERTFILE}}
RABBITMQ_HEARTBEAT_INTERVAL=${RABBITMQ_HEARTBEAT_INTERVAL:-10}
# To enable mirrored queue set it to 'all'
RABBITMQ_MIRRORED_QUEUE_MODE=${RABBITMQ_MIRRORED_QUEUE_MODE-'all'}

# Redis
REDIS_NODES=${REDIS_NODES:-${ANALYTICS_NODES}}
REDIS_SERVER_PORT=${REDIS_SERVER_PORT:-6379}
REDIS_SERVER_PASSWORD=${REDIS_SERVER_PASSWORD:-""}
# redis_servers MUST have same IP-s as analytics IP-s
# but redis must be installed on all nodes where analytics or webui are present
REDIS_SERVERS=${REDIS_SERVERS:-`get_server_list REDIS ":$REDIS_SERVER_PORT "`}
REDIS_LISTEN_ADDRESS=${REDIS_LISTEN_ADDRESS:-}
REDIS_PROTECTED_MODE=${REDIS_PROTECTED_MODE:-}
REDIS_SSL_ENABLE=${REDIS_SSL_ENABLE:-${SSL_ENABLE:-False}}
REDIS_SSL_CERTFILE=${REDIS_SSL_CERTFILE:-${SERVER_CERTFILE}}
REDIS_SSL_KEYFILE=${REDIS_SSL_KEYFILE:-${SERVER_KEYFILE}}
REDIS_SSL_CACERTFILE=${REDIS_SSL_CACERTFILE-${SERVER_CA_CERTFILE}}
if is_enabled ${REDIS_SSL_ENABLE} ; then
  read -r -d '' redis_ssl_config << EOM || true
redis_keyfile=$REDIS_SSL_KEYFILE
redis_certfile=$REDIS_SSL_CERTFILE
redis_ca_cert=$REDIS_SSL_CACERTFILE
EOM
else
  redis_ssl_config=''
fi

# Kafka
KAFKA_NODES=${KAFKA_NODES:-${ANALYTICS_ALARM_NODES}}
KAFKA_PORT=${KAFKA_PORT:-9092}
KAFKA_SERVERS=${KAFKA_SERVERS:-`get_server_list KAFKA ":$KAFKA_PORT "`}
KAFKA_SSL_ENABLE=${KAFKA_SSL_ENABLE:-${SSL_ENABLE:-False}}
KAFKA_SSL_CERTFILE=${KAFKA_SSL_CERTFILE:-${SERVER_CERTFILE}}
KAFKA_SSL_KEYFILE=${KAFKA_SSL_KEYFILE:-${SERVER_KEYFILE}}
KAFKA_SSL_CACERTFILE=${KAFKA_SSL_CACERTFILE-${SERVER_CA_CERTFILE}}

# Keystone authentication
KEYSTONE_AUTH_ADMIN_TENANT=${KEYSTONE_AUTH_ADMIN_TENANT:-admin}
KEYSTONE_AUTH_ADMIN_USER=${KEYSTONE_AUTH_ADMIN_USER:-admin}
KEYSTONE_AUTH_ADMIN_PASSWORD=${KEYSTONE_AUTH_ADMIN_PASSWORD:-contrail123}
KEYSTONE_AUTH_PROJECT_DOMAIN_NAME=${KEYSTONE_AUTH_PROJECT_DOMAIN_NAME:-Default}
KEYSTONE_AUTH_USER_DOMAIN_NAME=${KEYSTONE_AUTH_USER_DOMAIN_NAME:-Default}
KEYSTONE_AUTH_REGION_NAME=${KEYSTONE_AUTH_REGION_NAME:-RegionOne}
KEYSTONE_AUTH_URL_VERSION=${KEYSTONE_AUTH_URL_VERSION:-'/v3'}
KEYSTONE_AUTH_HOST=${KEYSTONE_AUTH_HOST:-'127.0.0.1'}
KEYSTONE_AUTH_PROTO=${KEYSTONE_AUTH_PROTO:-'http'}
KEYSTONE_AUTH_ADMIN_PORT=${KEYSTONE_AUTH_ADMIN_PORT:-'35357'}
KEYSTONE_AUTH_PUBLIC_PORT=${KEYSTONE_AUTH_PUBLIC_PORT:-'5000'}
KEYSTONE_AUTH_URL_TOKENS='/v3/auth/tokens'
KEYSTONE_AUTH_INSECURE=${KEYSTONE_AUTH_INSECURE:-${SSL_INSECURE}}
KEYSTONE_AUTH_CERTFILE=${KEYSTONE_AUTH_CERTFILE:-}
KEYSTONE_AUTH_KEYFILE=${KEYSTONE_AUTH_KEYFILE:-}
KEYSTONE_AUTH_CA_CERTFILE=${KEYSTONE_AUTH_CA_CERTFILE:-}
KEYSTONE_AUTH_ENDPOINT_TYPE=${KEYSTONE_AUTH_ENDPOINT_TYPE:-}
KEYSTONE_AUTH_SYNC_ON_DEMAND=${KEYSTONE_AUTH_SYNC_ON_DEMAND:-}

# Kubernetes
KUBEMANAGER_NODES=${KUBEMANAGER_NODES:-${CONFIG_NODES}}
KUBERNETES_API_NODES=${KUBERNETES_API_NODES:-${CONFIG_NODES}}

# vCenter
VCENTER_FABRIC_MANAGER_NODES=${VCENTER_FABRIC_MANAGER_NODES:-${CONFIG_NODES}}

# Metadata
METADATA_PROXY_SECRET=${METADATA_PROXY_SECRET:-'contrail'}

# OpenStack
BARBICAN_TENANT_NAME=${BARBICAN_TENANT_NAME:-service}
BARBICAN_USER=${BARBICAN_USER:-barbican}
BARBICAN_PASSWORD=${BARBICAN_PASSWORD:-${KEYSTONE_AUTH_ADMIN_PASSWORD}}

# vRouter
AGENT_MODE=${AGENT_MODE:-'kernel'}
EXTERNAL_ROUTERS=${EXTERNAL_ROUTERS:-""}
SUBCLUSTER=${SUBCLUSTER:-""}
VROUTER_COMPUTE_NODE_ADDRESS=${VROUTER_COMPUTE_NODE_ADDRESS:-""}
VROUTER_CRYPT_INTERFACE=${VROUTER_CRYPT_INTERFACE:-'crypt0'}
VROUTER_DECRYPT_INTERFACE=${VROUTER_DECRYPT_INTERFACE:-'decrypt0'}
VROUTER_DECRYPT_KEY=${VROUTER_DECRYPT_KEY:-'15'}
VROUTER_MODULE_OPTIONS=${VROUTER_MODULE_OPTIONS:-}
FABRIC_SNAT_HASH_TABLE_SIZE=${FABRIC_SNAT_HASH_TABLE_SIZE:-'4096'}
TSN_EVPN_MODE=${TSN_EVPN_MODE:-False}
TSN_NODES=${TSN_NODES:-[]}
# Qos configuration options
PRIORITY_ID=${PRIORITY_ID:-""}
PRIORITY_BANDWIDTH=${PRIORITY_BANDWIDTH:-""}
PRIORITY_SCHEDULING=${PRIORITY_SCHEDULING:-""}
QOS_QUEUE_ID=${QOS_QUEUE_ID:-""}
QOS_LOGICAL_QUEUES=${QOS_LOGICAL_QUEUES:-""}
QOS_DEF_HW_QUEUE=${QOS_DEF_HW_QUEUE:-False}
PRIORITY_TAGGING=${PRIORITY_TAGGING:-True}
# Session logging options
SLO_DESTINATION=${SLO_DESTINATION:-"collector"}
if [ -n "$XFLOW_NODE_IP" ] ; then
  SAMPLE_DESTINATION=${SAMPLE_DESTINATION:-"collector syslog"}
  FLOW_EXPORT_RATE=${FLOW_EXPORT_RATE:-100}
fi
SAMPLE_DESTINATION=${SAMPLE_DESTINATION:-"collector"}
FLOW_EXPORT_RATE=${FLOW_EXPORT_RATE:-0}

# Web UI
WEBUI_NODES=${WEBUI_NODES:-${CONTROLLER_NODES}}
WEBUI_JOB_SERVER_PORT=${WEBUI_JOB_SERVER_PORT:-3000}
KUE_UI_PORT=${KUE_UI_PORT:-3002}
WEBUI_HTTP_LISTEN_PORT=${WEBUI_HTTP_LISTEN_PORT:-8180}
WEBUI_HTTPS_LISTEN_PORT=${WEBUI_HTTPS_LISTEN_PORT:-8143}
WEBUI_SSL_KEY_FILE=${WEBUI_SSL_KEY_FILE:-'/etc/contrail/webui_ssl/cs-key.pem'}
WEBUI_SSL_CERT_FILE=${WEBUI_SSL_CERT_FILE:-'/etc/contrail/webui_ssl/cs-cert.pem'}
WEBUI_SSL_CIPHERS=${WEBUI_SSL_CIPHERS:-"ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:AES256-SHA"}
WEBUI_STATIC_AUTH_USER=${WEBUI_STATIC_AUTH_USER:-admin}
WEBUI_STATIC_AUTH_PASSWORD=${WEBUI_STATIC_AUTH_PASSWORD:-contrail123}
WEBUI_STATIC_AUTH_ROLE=${WEBUI_STATIC_AUTH_ROLE:-cloudAdmin}

# XMPP
XMPP_SERVER_PORT=${XMPP_SERVER_PORT:-5269}
XMPP_SSL_ENABLE=${XMPP_SSL_ENABLE:-${SSL_ENABLE}}
XMPP_SERVER_CERTFILE=${XMPP_SERVER_CERTFILE:-${SERVER_CERTFILE}}
XMPP_SERVER_KEYFILE=${XMPP_SERVER_KEYFILE:-${SERVER_KEYFILE}}
XMPP_SERVER_CA_CERTFILE=${XMPP_SERVER_CA_CERTFILE-${SERVER_CA_CERTFILE}}

# Node manager
LINKLOCAL_SERVICE_PORT=${LINKLOCAL_SERVICE_PORT:-80}
LINKLOCAL_SERVICE_NAME=${LINKLOCAL_SERVICE_NAME:-'metadata'}
LINKLOCAL_SERVICE_IP=${LINKLOCAL_SERVICE_IP:-'169.254.169.254'}
# this is group of parameters where OpenStack metadata service can be found
IPFABRIC_SERVICE_PORT=${IPFABRIC_SERVICE_PORT:-8775}
#IPFABRIC_SERVICE_HOST can be derived here and can't have default value

# Introspect
INTROSPECT_SSL_ENABLE=${INTROSPECT_SSL_ENABLE:-${SSL_ENABLE}}
INTROSPECT_SSL_INSECURE=${INTROSPECT_SSL_INSECURE:-${SSL_INSECURE}}
INTROSPECT_CERTFILE=${INTROSPECT_CERTFILE:-${SERVER_CERTFILE}}
INTROSPECT_KEYFILE=${INTROSPECT_KEYFILE:-${SERVER_KEYFILE}}
INTROSPECT_CA_CERTFILE=${INTROSPECT_CA_CERTFILE-${SERVER_CA_CERTFILE}}
# Set this to False if introspect services is required to be on specific
# interface IP. The default is to listen on 0.0.0.0
INTROSPECT_LISTEN_ALL=${INTROSPECT_LISTEN_ALL:-True}

# Sandesh
SANDESH_SSL_ENABLE=${SANDESH_SSL_ENABLE:-${SSL_ENABLE}}
SANDESH_CERTFILE=${SANDESH_CERTFILE:-${SERVER_CERTFILE}}
SANDESH_KEYFILE=${SANDESH_KEYFILE:-${SERVER_KEYFILE}}
SANDESH_CA_CERTFILE=${SANDESH_CA_CERTFILE-${SERVER_CA_CERTFILE}}

# Metadata service SSL opts
METADATA_SSL_ENABLE=${METADATA_SSL_ENABLE:-false}
METADATA_SSL_CERTFILE=${METADATA_SSL_CERTFILE:-}
METADATA_SSL_KEYFILE=${METADATA_SSL_KEYFILE:-}
METADATA_SSL_CA_CERTFILE=${METADATA_SSL_CA_CERTFILE:-}
METADATA_SSL_CERT_TYPE=${METADATA_SSL_CERT_TYPE:-}

# IP tables
CONFIGURE_IPTABLES=${CONFIGURE_IPTABLES:-'false'}

# FWAAS
FWAAS_ENABLE=${FWAAS_ENABLE:-False}

# Tor
TOR_AGENT_OVS_KA=${TOR_AGENT_OVS_KA:-'10000'}
TOR_TYPE=${TOR_TYPE:-'ovs'}
TOR_OVS_PROTOCOL=${TOR_OVS_PROTOCOL:-'tcp'}
TORAGENT_SSL_CERTFILE=${TORAGENT_SSL_CERTFILE:-${SERVER_CERTFILE}}
TORAGENT_SSL_KEYFILE=${TORAGENT_SSL_KEYFILE:-${SERVER_KEYFILE}}
TORAGENT_SSL_CACERTFILE=${TORAGENT_SSL_CACERTFILE:-${SERVER_CA_CERTFILE}}

if [[ "$KEYSTONE_AUTH_URL_VERSION" == '/v2.0' ]] ; then
  KEYSTONE_AUTH_URL_TOKENS='/v2.0/tokens'
fi

if [[ $CLOUD_ORCHESTRATOR == 'openstack' ]] ; then
  AUTH_MODE='keystone'
fi

if [[ "$AUTH_MODE" == 'keystone' ]] ; then
  AUTH_PARAMS="--admin_password $KEYSTONE_AUTH_ADMIN_PASSWORD"
  AUTH_PARAMS+=" --admin_tenant_name $KEYSTONE_AUTH_ADMIN_TENANT"
  AUTH_PARAMS+=" --admin_user $KEYSTONE_AUTH_ADMIN_USER"
fi


if is_enabled ${INTROSPECT_SSL_ENABLE} ; then
  read -r -d '' sandesh_client_config << EOM || true
[SANDESH]
introspect_ssl_enable=${INTROSPECT_SSL_ENABLE}
introspect_ssl_insecure=${INTROSPECT_SSL_INSECURE}
sandesh_ssl_enable=${SANDESH_SSL_ENABLE}
sandesh_keyfile=${SANDESH_KEYFILE}
sandesh_certfile=${SANDESH_CERTFILE}
sandesh_ca_cert=${SANDESH_CA_CERTFILE}
EOM
else
  read -r -d '' sandesh_client_config << EOM || true
[SANDESH]
introspect_ssl_enable=${INTROSPECT_SSL_ENABLE}
sandesh_ssl_enable=${SANDESH_SSL_ENABLE}
EOM
fi

if is_enabled ${XMPP_SSL_ENABLE} ; then
  read -r -d '' xmpp_certs_config << EOM || true
xmpp_server_cert=${XMPP_SERVER_CERTFILE}
xmpp_server_key=${XMPP_SERVER_KEYFILE}
xmpp_ca_cert=${XMPP_SERVER_CA_CERTFILE}
EOM
else
  xmpp_certs_config=''
fi

if is_enabled ${ANALYTICS_API_SSL_ENABLE} ; then
  read -r -d '' analytics_api_ssl_opts << EOM || true
analytics_api_ssl_enable = ${ANALYTICS_API_SSL_ENABLE}
analytics_api_insecure_enable = ${ANALYTICS_API_SSL_INSECURE}
analytics_api_ssl_certfile = ${ANALYTICS_API_SERVER_CERTFILE}
analytics_api_ssl_keyfile = ${ANALYTICS_API_SERVER_KEYFILE}
analytics_api_ssl_ca_cert = ${ANALYTICS_API_SERVER_CA_CERTFILE}
EOM
else
  analytics_api_ssl_opts=''
fi

# first group is used in analytics and control services
# second group is used in config service, kubernetes_manager, ironic_notification_manager
read -r -d '' rabbitmq_config << EOM || true
rabbitmq_vhost=$RABBITMQ_VHOST
rabbitmq_user=$RABBITMQ_USER
rabbitmq_password=$RABBITMQ_PASSWORD
rabbitmq_use_ssl=$RABBITMQ_USE_SSL
EOM
read -r -d '' rabbit_config << EOM || true
rabbit_vhost=$RABBITMQ_VHOST
rabbit_user=$RABBITMQ_USER
rabbit_password=$RABBITMQ_PASSWORD
rabbit_use_ssl=$RABBITMQ_USE_SSL
rabbit_health_check_interval=$RABBITMQ_HEARTBEAT_INTERVAL
EOM

if is_enabled ${RABBITMQ_USE_SSL} ; then
  read -r -d '' rabbitmq_ssl_config << EOM || true
rabbitmq_ssl_version=$RABBITMQ_SSL_VER
rabbitmq_ssl_keyfile=$RABBITMQ_CLIENT_SSL_KEYFILE
rabbitmq_ssl_certfile=$RABBITMQ_CLIENT_SSL_CERTFILE
rabbitmq_ssl_ca_certs=$RABBITMQ_CLIENT_SSL_CACERTFILE
EOM
  read -r -d '' kombu_ssl_config << EOM || true
kombu_ssl_version=$RABBITMQ_SSL_VER
kombu_ssl_certfile=$RABBITMQ_CLIENT_SSL_CERTFILE
kombu_ssl_keyfile=$RABBITMQ_CLIENT_SSL_KEYFILE
kombu_ssl_ca_certs=$RABBITMQ_CLIENT_SSL_CACERTFILE
EOM
fi

if is_enabled ${KAFKA_SSL_ENABLE} ; then
  read -r -d '' kafka_ssl_config << EOM || true
kafka_keyfile=$KAFKA_SSL_KEYFILE
kafka_certfile=$KAFKA_SSL_CERTFILE
kafka_ca_cert=$KAFKA_SSL_CACERTFILE
EOM
else
  kafka_ssl_config=''
fi

if [[ -n "$STATS_COLLECTOR_DESTINATION_PATH" ]]; then
  read -r -d '' collector_stats_config << EOM || true
[STATS]
stats_collector=${STATS_COLLECTOR_DESTINATION_PATH}
EOM
else
  collector_stats_config=''
fi

if [[ -z ${TSN_AGENT_MODE+x} ]]; then
  # TSN_AGENT_MODE is not set - check old interface
  if is_enabled ${TSN_EVPN_MODE} ; then
    export TSN_AGENT_MODE="tsn-no-forwarding"
  else
    export TSN_AGENT_MODE=""
  fi
fi
if [[ -n "$STATS_COLLECTOR_DESTINATION_PATH" ]]; then
  read -r -d '' collector_stats_config << EOM || true
[STATS]
stats_collector=${STATS_COLLECTOR_DESTINATION_PATH}
EOM
else
  collector_stats_config=''
fi

if [[ -z ${TSN_AGENT_MODE+x} ]]; then
  # TSN_AGENT_MODE is not set - check old interface
  if is_enabled ${TSN_EVPN_MODE} ; then
    export TSN_AGENT_MODE="tsn-no-forwarding"
  else
    export TSN_AGENT_MODE=""
  fi
fi

RSYSLOGD_XFLOW_LISTEN_PORT=${RSYSLOGD_XFLOW_LISTEN_PORT:-9898}
