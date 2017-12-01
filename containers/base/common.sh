#!/bin/bash

DEFAULT_IFACE=`ip -4 route list 0/0 | awk '{ print $5; exit }'`
DEFAULT_LOCAL_IP=`ip addr | grep $DEFAULT_IFACE | grep 'inet ' | awk '{print $2}' | cut -d '/' -f 1`
DEFAULT_HOSTNAME=`uname -n`

CLOUD_ORCHESTRATOR=${CLOUD_ORCHESTRATOR:-kubernetes}
AAA_MODE=${AAA_MODE:-no-auth}
AUTH_MODE='noauth'
if [[ $CLOUD_ORCHESTRATOR == 'openstack' && $AAA_MODE != 'no-auth' ]] ; then
  AUTH_MODE='keystone'
fi

CONTROLLER_NODES=${CONTROLLER_NODES:-${DEFAULT_LOCAL_IP}}

CONFIG_NODES=${CONFIG_NODES:-${CONTROLLER_NODES}}
CONTROL_NODES=${CONTROL_NODES:-${CONFIG_NODES}}
CONFIGDB_NODES=${CONFIGDB_NODES:-${CONFIG_NODES}}
ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-${CONFIG_NODES}}
RABBITMQ_NODES=${RABBITMQ_NODES:-${CONFIG_NODES}}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}
REDIS_NODES=${REDIS_NODES:-${ANALYTICS_NODES}}
ANALYTICSDB_NODES=${ANALYTICSDB_NODES:-${ANALYTICS_NODES}}
KAFKA_NODES=${KAFKA_NODES:-${ANALYTICSDB_NODES}}

CONTROL_INTROSPECT_PORT=${CONTROL_INTROSPECT_PORT:-8083}
BGP_PORT=${BGP_PORT:-179}
BGP_AUTO_MESH=${BGP_AUTO_MESH:-'true'}
XMPP_SERVER_PORT=${XMPP_SERVER_PORT:-5269}
DNS_SERVER_PORT=${DNS_SERVER_PORT:-53}
DNS_INTROSPECT_PORT=${DNS_INTROSPECT_PORT:-8092}
CONFIG_API_PORT=${CONFIG_API_PORT:-8082}
CONFIG_API_INTROSPECT_PORT=${CONFIG_API_INTROSPECT_PORT:-8084}
RABBITMQ_PORT=${RABBITMQ_PORT:-5672}
CONFIGDB_PORT=${CONFIGDB_PORT:-9161}
CONFIGDB_CQL_PORT=${CONFIGDB_CQL_PORT:-9041}
ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
WEBUI_JOB_SERVER_PORT=${WEBUI_JOB_SERVER_PORT:-3000}
KUE_UI_PORT=${KUE_UI_PORT:-3002}
WEBUI_HTTP_LISTEN_PORT=${WEBUI_HTTP_LISTEN_PORT:-8180}
WEBUI_HTTPS_LISTEN_PORT=${WEBUI_HTTPS_LISTEN_PORT:-8143}
ANALYTICS_API_PORT=${ANALYTCS_API_PORT:-8081}
ANALYTICS_API_INTROSPECT_PORT=${ANALYTICS_API_INTROSPECT_PORT:-8090}
COLLECTOR_PORT=${COLLECTOR_PORT:-8086}
COLLECTOR_INTROSPECT_PORT=${COLLECTOR_INTROSPECT_PORT:-8089}
COLLECTOR_SYSLOG_PORT=${COLLECTOR_SYSLOG_PORT:-514}
COLLECTOR_SFLOW_PORT=${COLLECTOR_SFLOW_PORT:-6343}
COLLECTOR_IPFIX_PORT=${COLLECTOR_IPFIX_PORT:-4739}
COLLECTOR_PROTOBUF_PORT=${COLLECTOR_PROTOBUF_PORT:-3333}
COLLECTOR_STRUCTURED_SYSLOG_PORT=${COLLECTOR_STRUCTURED_SYSLOG_PORT:-3514}
ALARMGEN_INTROSPECT_PORT=${ALARMGEN_INTROSPECT_PORT:-5995}
QUERYENGINE_INTROSPECT_PORT=${QUERYENGINE_INTROSPECT_PORT:-8091}
SNMPCOLLECTOR_INTROSPECT_PORT=${SNMPCOLLECTOR_INTROSPECT_PORT:-5920}
TOPOLOGY_INTROSPECT_PORT=${TOPOLOGY_INTROSPECT_PORT:-5921}
REDIS_SERVER_PORT=${REDIS_SERVER_PORT:-6379}
ANALYTICSDB_PORT=${ANALYTICSDB_PORT:-9160}
ANALYTICSDB_CQL_PORT=${ANALYTICSDB_CQL_PORT:-9042}
KAFKA_PORT=${KAFKA_PORT:-9092}

RABBITMQ_VHOST=${RABBITMQ_VHOST:-/}
RABBITMQ_USER=${RABBITMQ_USER:-guest}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD:-guest}
RABBITMQ_USE_SSL=${RABBITMQ_USE_SSL:-False}

REDIS_SERVER_IP=${REDIS_SERVER_IP:-127.0.0.1}
REDIS_SERVER_PASSWORD=${REDIS_SERVER_PASSWORD:-""}

LOG_DIR=${LOG_DIR:-"/var/log/contrail"}
LOG_LEVEL=${LOG_LEVEL:-SYS_NOTICE}
LOG_LOCAL=${LOG_LOCAL:-1}

BGP_ASN=${BGP_ASN:-64512}
RNDC_KEY=${RNDC_KEY:-"xvysmOR8lnUQRBcunkC6vg=="}

KEYSTONE_AUTH_ADMIN_TENANT=${KEYSTONE_AUTH_ADMIN_TENANT:-admin}
KEYSTONE_AUTH_ADMIN_USER=${KEYSTONE_AUTH_ADMIN_USER:-admin}
KEYSTONE_AUTH_ADMIN_PASSWORD=${KEYSTONE_AUTH_ADMIN_PASSWORD:-contrail123}
KEYSTONE_AUTH_PROJECT_DOMAIN_NAME=${KEYSTONE_AUTH_PROJECT_DOMAIN_NAME:-Default}
KEYSTONE_AUTH_USER_DOMAIN_NAME=${KEYSTONE_AUTH_USER_DOMAIN_NAME:-Default}

KEYSTONE_AUTH_URL_VERSION=${KEYSTONE_AUTH_URL_VERSION:-'/v2.0'}
KEYSTONE_AUTH_HOST=${KEYSTONE_AUTH_HOST:-'127.0.0.1'}
KEYSTONE_AUTH_PROTO=${KEYSTONE_AUTH_PROTO:-'http'}
KEYSTONE_AUTH_ADMIN_PORT=${KEYSTONE_AUTH_ADMIN_PORT:-'35357'}
KEYSTONE_AUTH_PUBLIC_PORT=${KEYSTONE_AUTH_PUBLIC_PORT:-'5000'}

KEYSTONE_AUTH_URL_TOKENS='/v2.0/tokens'
if [[ "$KEYSTONE_AUTH_URL_VERSION" == '/v3' ]] ; then
  KEYSTONE_AUTH_URL_TOKENS='/v3/auth/tokens'
fi

AUTH_PARAMS=''
if [[ "$AUTH_MODE" == 'keystone' ]] ; then
  AUTH_PARAMS="--admin_password $KEYSTONE_AUTH_ADMIN_PASSWORD"
  AUTH_PARAMS+=" --admin_tenant_name $KEYSTONE_AUTH_ADMIN_TENANT"
  AUTH_PARAMS+=" --admin_user $KEYSTONE_AUTH_ADMIN_USER"
#  AUTH_PARAMS+=" --openstack_ip $KEYSTONE_AUTH_HOST"
fi

source /functions.sh

CONFIG_SERVERS=${CONFIG_SERVERS:-`get_server_list CONFIG ":$CONFIG_API_PORT "`}
CONFIGDB_SERVERS=${CONFIGDB_SERVERS:-`get_server_list CONFIGDB ":$CONFIGDB_PORT "`}
CONFIGDB_CQL_SERVERS=${CONFIGDB_CQL_SERVERS:-`get_server_list CONFIGDB ":$CONFIGDB_CQL_PORT "`}
ZOOKEEPER_SERVERS=${ZOOKEEPER_SERVERS:-`get_server_list ZOOKEEPER ":$ZOOKEEPER_PORT,"`}
ZOOKEEPER_SERVERS_SPACE_DELIM=${ZOOKEEPER_SERVERS:-`get_server_list ZOOKEEPER ":$ZOOKEEPER_PORT "`}
RABBITMQ_SERVERS=${RABBITMQ_SERVERS:-`get_server_list RABBITMQ ":$RABBITMQ_PORT,"`}
ANALYTICS_SERVERS=${ANALYTICS_SERVERS:-`get_server_list ANALYTICS ":$ANALYTICS_API_PORT "`}
COLLECTOR_SERVERS=${COLLECTOR_SERVERS:-`get_server_list ANALYTICS ":$COLLECTOR_PORT "`}
REDIS_SERVERS=${REDIS_SERVERS:-`get_server_list REDIS ":$REDIS_SERVER_PORT "`}
ANALYTICSDB_SERVERS=${ANALYTICSDB_SERVERS:-`get_server_list ANALYTICSDB ":$ANALYTICSDB_PORT "`}
ANALYTICSDB_CQL_SERVERS=${ANALYTICSDB_CQL_SERVERS:-`get_server_list ANALYTICSDB ":$ANALYTICSDB_CQL_PORT "`}
KAFKA_SERVERS=${KAFKA_SERVERS:-`get_server_list KAFKA ":$KAFKA_PORT "`}

ANALYTICS_API_VIP=${ANALYTICS_API_VIP:-$(get_vip_for_node ANALYTICS)}
CONFIG_API_VIP=${CONFIG_API_VIP:-$(get_vip_for_node CONFIG)}
WEBUI_VIP=${WEBUI_VIP:-$(get_vip_for_node CONFIG)}

LINKLOCAL_SERVICE_PORT=${LINKLOCAL_SERVICE_PORT:-80}
LINKLOCAL_SERVICE_NAME=${LINKLOCAL_SERVICE_NAME:-'metadata'}
LINKLOCAL_SERVICE_IP=${LINKLOCAL_SERVICE_IP:-'169.254.169.254'}

IPFABRIC_SERVICE_PORT=${IPFABRIC_SERVICE_PORT:-8775}
IPFABRIC_SERVICE_IP=${IPFABRIC_SERVICE_IP:-${CONFIG_API_VIP}}

read -r -d '' sandesh_client_config << EOM
[SANDESH]
sandesh_ssl_enable=${SANDESH_SSL_ENABLE:-False}
introspect_ssl_enable=${INTROSPECT_SSL_ENABLE:-False}
sandesh_keyfile=${SANDESH_KEYFILE:-/etc/contrail/ssl/private/server-privkey.pem}
sandesh_certfile=${SANDESH_CERTFILE:-/etc/contrail/ssl/certs/server.pem}
sandesh_ca_cert=${SANDESH_CA_CERT:-/etc/contrail/ssl/certs/ca-cert.pem}
EOM

