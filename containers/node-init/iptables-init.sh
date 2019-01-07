#!/bin/bash

source /common.sh

#
# Script to configure iptables rules on a node.
#
# This script works off the following environment variables:
#
# IPTABLES_OPEN_PORTS -> Ports to be opened up in iptables, delimited by ','.
#                        Multiple ports or port-ranges may be specified.
#                        Default value is '', the ports are derived from the type of
#                        container which is created (the CONTRAIL_SVC_NAME env).
# IPTABLES_CHAIN      -> Name of the chain in iptables.
#                        This chain, if specified, MUST exist.
#                        Default value is "INPUT"
# IPTABLES_TABLE      -> Name of the table in iptables.
#                        This table, if specified, MUST exist.
#                        Default value is "filter"
# CONFIGURE_IPTABLES  -> Set to true/yes/enabled if iptable configuration is
#                        being required.
#                        Default value is 'false'
#
# Script returns the following return value:
#
# 0 - Success
# 1 - All failures.
#

# Configure iptable rules if requested.
if [[ "${CONFIGURE_IPTABLES}" == 'false' || "${CONFIGURE_IPTABLES}" == 'no' || "${CONFIGURE_IPTABLES}" == 'disabled' ]]; then
  exit
fi

script_name=`basename "$0"`

KUBEMANAGER_INTROSPECT_PORT=${KUBEMANAGER_INTROSPECT_PORT:-8108}
CONTROL_DNS_XMPP_PORT=${CONTROL_DNS_XMPP_PORT:-8093}

ZOOKEEPER_ANALYTICS_ARB_PORT_1=${ZOOKEEPER_ANALYTICS_ARB_PORT_1:-40799}
ZOOKEEPER_ANALYTICS_ARB_PORT_2=${ZOOKEEPER_ANALYTICS_ARB_PORT_2:-4888}
ZOOKEEPER_ANALYTICS_ARB_PORT_3=${ZOOKEEPER_ANALYTICS_ARB_PORT_3:-5888}

ANALYTICS_NODEMGR_INTROSPECT_PORT=${ANALYTICS_NODEMGR_INTROSPECT_PORT:-8104}

KAFKA_ARB_PORT=${KAFKA_ARB_PORT:-33994}

CONTROLLER_DATABASE_NODEMGR_PORT=${CONTROLLER_DATABASE_NODEMGR_PORT:-8103}

RABBITMQ_ARB_PORT_1=${RABBITMQ_ARB_PORT_1:-4369}
RABBITMQ_ARB_PORT_2=${RABBITMQ_ARB_PORT_2:-`expr $RABBITMQ_NODE_PORT + 20000`}

CONFIG_API_BACKEND_PORT=${CONFIG_API_BACKEND_PORT:-9100}

CONFIG_NODEMGR_PORT=${CONFIG_NODEMGR_PORT:-8100}
CONFIG_DEVICE_MANAGER_PORT=${CONFIG_DEVICE_MANAGER:-8096}
CONFIG_SVC_MONITOR_PORT=${CONFIG_SVC_MONITOR:-8088}
CONFIG_SCHEMA_TRANSFORMER_PORT=${CONFIG_SCHEMA_TRANSFORMER_PORT:-8087}

CONFIG_ZOOKEEPER_ARB_PORT=${CONFIG_ZOOKEEPER_ARB_PORT:-43391}

CONFIG_DATABASE_NODEMGR_PORT=${CONFIG_DATABASE_NODEMGR:-8112}
VROUTER_AGENT_INTROSPECT_PORT=${VROUTER_AGENT_INTROSPECT_PORT:-8085}
VROUTER_AGENT_METADATA_PROXY_PORT=${VROUTER_AGENT_METADATA_PROXY_PORT:-8097}
VROUTER_PORT=${VROUTER_PORT:-9091}
VROUTER_AGENT_NODEMGR_PORT=${VROUTER_AGENT_NODEMGR_PORT:-8102}
KUBERNETES_API_PORT=${KUBERNETES_API_PORT:-8080}
CONTROL_NODEMGR_PORT=${CONTROL_NODEMGR_PORT:-8101}

if [[ -z "$CONTRAIL_SVC_NAME" ]]; then
  echo "Contrail Service name is not set, please set service name using CONTRAIL_SVC_NAME"
  exit 1
fi

case "$CONTRAIL_SVC_NAME" in
    "vrouter")
        ports="$VROUTER_AGENT_INTROSPECT_PORT $VROUTER_AGENT_METADATA_PROXY_PORT $VROUTER_PORT $VROUTER_AGENT_NODEMGR_PORT";;
    "redis")
        ports="$REDIS_SERVER_PORT";;
    "config_db_nodemgr")
        ports="$CONFIG_DATABASE_NODEMGR_PORT";;
    "config_cassandra")
        ports="$CONFIGDB_PORT "
        ports+="$CASSANDRA_JMX_LOCAL_PORT "
        ports+="$CASSANDRA_SSL_STORAGE_PORT "
        ports+="$CASSANDRA_STORAGE_PORT "
        ports+="$CASSANDRA_CQL_PORT";;
    "config_zookeeper")
        ports="$ZOOKEEPER_PORT $CONFIG_ZOOKEEPER_ARB_PORT $ZOOKEEPER_PORTS";;
    "config")
        ports="$CONFIG_API_PORT $CONFIGDB_CQL_PORT $CONFIG_API_INTROSPECT_PORT "
        ports+="$CONFIG_SCHEMA_TRANSFORMER_PORT "
        ports+="$CONFIG_SVC_MONITOR_PORT "
        ports+="$CONFIG_DEVICE_MANAGER_PORT "
        ports+="$CONFIG_NODEMGR_PORT "
        ports+="$CONFIG_API_BACKEND_PORT "
        ports+="$COLLECTOR_SYSLOG_PORT $COLLECTOR_SFLOW_PORT $COLLECTOR_IPFIX_PORT $COLLECTOR_PROTOBUF_PORT";;
    "contrail_webui")
        ports="$WEBUI_HTTPS_LISTEN_PORT $WEBUI_HTTP_LISTEN_PORT";;
    "rabbitMQ")
        ports="$RABBITMQ_ARB_PORT_1 $RABBITMQ_ARB_PORT_2 $RABBITMQ_NODE_PORT";;
    "controller_db_nodemgr")
        ports="$CONTROLLER_DATABASE_NODEMGR_PORT";;
    "kafka")
        ports="$KAFKA_PORT $KAFKA_ARB_PORT";;
    "analytics_cassandra")
        ports="$CASSANDRA_PORT "
        ports+="$CASSANDRA_JMX_LOCAL_PORT "
        ports+="$CASSANDRA_SSL_STORAGE_PORT "
        ports+="$CASSANDRA_STORAGE_PORT "
        ports+="$CASSANDRA_CQL_PORT";;
    "analytics_zookeeper")
        ports="$ZOOKEEPER_ANALYTICS_PORT $ZOOKEEPER_ANALYTICS_ARB_PORT_1 $ZOOKEEPER_ANALYTICS_ARB_PORT_2 $ZOOKEEPER_ANALYTICS_ARB_PORT_3";;
    "analytics")
        ports="$ANALYTICS_API_INTROSPECT_PORT $ANALYTICS_API_PORT "
        ports+="$COLLECTOR_INTROSPECT_PORT $COLLECTOR_PORT $COLLECTOR_STRUCTURED_SYSLOG_PORT "
        ports+="$QUERYENGINE_INTROSPECT_PORT "
        ports+="$SNMPCOLLECTOR_INTROSPECT_PORT "
        ports+="$TOPOLOGY_INTROSPECT_PORT "
        ports+="$ANALYTICS_NODEMGR_INTROSPECT_PORT "
        ports+="$ALARMGEN_INTROSPECT_PORT";;
    "control")
        ports="$XMPP_SERVER_PORT $DNS_SERVER_PORT $CONTROL_INTROSPECT_PORT $CONTROL_NODEMGR_PORT $DNS_INTROSPECT_PORT $CONTROL_DNS_XMPP_PORT $BGP_PORT";;
    "kubemanager")
        ports="$KUBEMANAGER_INTROSPECT_PORT $KUBERNETES_API_PORT";;
    *)
        ports=''
        echo "No proper contrail svc name is provided, no iptables will be configured"
esac
echo "Opening ports $ports"

IPT_TABLE_NAME=${IPTABLES_TABLE:-'filter'}
IPT_CHAIN_NAME=${IPTABLES_CHAIN:-'INPUT'}

echo "$script_name: Configuring iptable rules to open port/s: [$ports] in chain: [$IPT_CHAIN_NAME] in Table: [$IPT_TABLE_NAME]"

# Check if the requested chain exists.

echo "$script_name: Validate that chain [$IPT_CHAIN_NAME] / table [$IPT_TABLE_NAME] exists."
iptables --list $IPT_CHAIN_NAME -t $IPT_TABLE_NAME -n
if [ $? -ne 0 ]; then
  echo "$script_name: Chain [$IPT_CHAIN_NAME] does not exist in table [$IPT_TABLE_NAME]"
  echo "$script_name: Exiting with failure."
  exit 1
fi

# Deduce the list of ports to be opened/allowed.

for port in $ports; do

  # Deduce if any rule for this port already exists in the requested chain..
  iptables --list $IPT_CHAIN_NAME -t $IPT_TABLE_NAME -n | grep -o -E 'dpt:[0-9]+' | cut -f 2 -d ':' | grep -qw $port
  rule_exists=$?

  if  [ $rule_exists  -ne 0 ] ; then
    # No rule targeting this port exists in the requested chain.
    echo "$script_name: Adding rule: iptables -t $IPT_TABLE_NAME -I $IPT_CHAIN_NAME 1 -w 5 -W 100000 -p tcp --dport $port -j ACCEPT"
    iptables -t $IPT_TABLE_NAME -I $IPT_CHAIN_NAME 1 -w 5 -W 100000 -p tcp --dport $port -j ACCEPT
    add_result=$?

    if [ $add_result -ne 0 ]; then
      echo "$script_name: ERROR Adding rule: iptables -t $IPT_TABLE_NAME -I $IPT_CHAIN_NAME 1 -w 5 -W 100000 -p tcp --dport $port -j ACCEPT"
      echo "$script_name: Exiting with failure."
      exit 1
    fi
  else
    echo "$script_name: A rule for port [$port] exists in chain [$IPT_CHAIN_NAME] table [$IPT_TABLE_NAME]. Skipping config for this port."
  fi
done

