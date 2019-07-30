#!/bin/bash

source /common.sh
#
# Script to configure firewalld or IPTables on a node.
#
# This script works off the following environment variables:
#
# FIREWALL_ZONE        -> Name of the zone in firewalld.
#                         This zone, if specified, MUST exist.
#                         Default value is "public"
# CONFIGURE_FIREWALLD  -> Set to true/yes/enabled if firewalld configuration is
#                         being required.
# NODE_TYPE            -> Name of the contrail node type, can be analytics,
#                         vrouter, database, config-database, config, control,
#                         analytics-snmp, analytics-alarm, webui, kubernetes.
#                         Any other value will result in failure.
# IPTABLES_CHAIN      -> Name of the chain in iptables.
#                        This chain, if specified, MUST exist.
#                        Default value is "INPUT"
# IPTABLES_TABLE      -> Name of the table in iptables.
#                        This table, if specified, MUST exist.
#                        Default value is "filter"
# CONFIGURE_IPTABLES  -> Set to true/yes/enabled if iptable configuration is
#                        being required.
#                        Default value is 'false'

# Script returns the following return value:
#
# 0 - Success
# 1 - All failures.
#



#Exit if neither are requested.
if !( is_enabled $CONFIGURE_IPTABLES || is_enabled $CONFIGURE_FIREWALLD ); then
  exit
fi
script_name=`basename "$0"`

KUBEMANAGER_INTROSPECT_PORT=${KUBEMANAGER_INTROSPECT_PORT:-8108}
CONTROL_DNS_XMPP_PORT=${CONTROL_DNS_XMPP_PORT:-8093}
ANALYTICS_NODEMGR_PORT=${ANALYTICS_NODEMGR_PORT:-8104}
CONTROLLER_DATABASE_NODEMGR_PORT=${CONTROLLER_DATABASE_NODEMGR_PORT:-8103}
RABBITMQ_EPMD_PORT=${RABBITMQ_EPMD_PORT:-4369}
RABBITMQ_DIST_PORT=${RABBITMQ_DIST_PORT:-`expr $RABBITMQ_NODE_PORT + 20000`}
CONFIG_NODEMGR_PORT=${CONFIG_NODEMGR_PORT:-8100}
CONFIG_DEVICE_MANAGER_INTROSPECT_PORT=${CONFIG_DEVICE_MANAGER_INTROSPECT_PORT:-8096}
CONFIG_SVC_MONITOR_INTROSPECT_PORT=${CONFIG_SVC_MONITOR_INTROSPECT_PORT:-8088}
CONFIG_SCHEMA_TRANSFORMER_INTROSPECT_PORT=${CONFIG_SCHEMA_TRANSFORMER_INTROSPECT_PORT:-8087}
CONFIG_DATABASE_NODEMGR_PORT=${CONFIG_DATABASE_NODEMGR_PORT:-8112}
VROUTER_AGENT_INTROSPECT_PORT=${VROUTER_AGENT_INTROSPECT_PORT:-8085}
VROUTER_AGENT_METADATA_PROXY_PORT=${VROUTER_AGENT_METADATA_PROXY_PORT:-8097}
VROUTER_PORT=${VROUTER_PORT:-9091}
VROUTER_AGENT_NODEMGR_PORT=${VROUTER_AGENT_NODEMGR_PORT:-8102}
KUBERNETES_API_PORT=${KUBERNETES_API_PORT:-8080}
CONTROL_NODEMGR_PORT=${CONTROL_NODEMGR_PORT:-8101}

if [[ -z "$NODE_TYPE" ]]; then
  echo "Contrail Node type is not set, please set contrail node type using NODE_TYPE"
  exit 1
fi

case "$NODE_TYPE" in
    "vrouter")
        ports="$VROUTER_AGENT_INTROSPECT_PORT $VROUTER_AGENT_METADATA_PROXY_PORT $VROUTER_PORT $VROUTER_AGENT_NODEMGR_PORT";;
    "analytics")
        ports="$ANALYTICS_API_INTROSPECT_PORT $ANALYTICS_API_PORT "
        ports+="$COLLECTOR_INTROSPECT_PORT $COLLECTOR_PORT $COLLECTOR_STRUCTURED_SYSLOG_PORT "
        ports+="$ANALYTICS_NODEMGR_PORT "
        ports+="$REDIS_SERVER_PORT";;
    "analytics-alarm")
        ports="$ALARMGEN_INTROSPECT_PORT "
        ports+="$KAFKA_PORT "
        ports+="$REDIS_SERVER_PORT";;
    "database")
        ports="$CASSANDRA_PORT "
        ports+="$ANALYTICSDB_PORT "
        ports+="$CASSANDRA_JMX_LOCAL_PORT "
        ports+="$CASSANDRA_SSL_STORAGE_PORT "
        ports+="$CASSANDRA_STORAGE_PORT "
        ports+="$CASSANDRA_CQL_PORT "
        ports+="$QUERYENGINE_INTROSPECT_PORT";;
    "analytics-snmp")
        ports="$SNMPCOLLECTOR_INTROSPECT_PORT "
        ports+="$TOPOLOGY_INTROSPECT_PORT "
        ports+="$REDIS_SERVER_PORT";;
    "config-database")
        ports="$CONFIG_DATABASE_NODEMGR_PORT "
        ports+="$CONFIGDB_PORT "
        ports+="$CASSANDRA_JMX_LOCAL_PORT "
        ports+="$CASSANDRA_SSL_STORAGE_PORT "
        ports+="$CASSANDRA_STORAGE_PORT "
        ports+="$CASSANDRA_CQL_PORT "
        ports+="$ZOOKEEPER_PORT $ZOOKEEPER_PORTS "
        ports+="$RABBITMQ_EPMD_PORT $RABBITMQ_DIST_PORT $RABBITMQ_NODE_PORT";;
    "config")
        ports="$CONFIG_API_PORT $CONFIGDB_CQL_PORT $CONFIG_API_INTROSPECT_PORT "
        ports+="$CONFIG_SCHEMA_TRANSFORMER_INTROSPECT_PORT "
        ports+="$CONFIG_SVC_MONITOR_INTROSPECT_PORT "
        ports+="$CONFIG_DEVICE_MANAGER_INTROSPECT_PORT "
        ports+="$CONFIG_NODEMGR_PORT "
        ports+="$COLLECTOR_SYSLOG_PORT $COLLECTOR_SFLOW_PORT $COLLECTOR_IPFIX_PORT $COLLECTOR_PROTOBUF_PORT";;
    "webui")
        ports="$WEBUI_HTTPS_LISTEN_PORT $WEBUI_HTTP_LISTEN_PORT "
        ports+="$REDIS_SERVER_PORT";;
    "control")
        ports="$XMPP_SERVER_PORT $DNS_SERVER_PORT $CONTROL_INTROSPECT_PORT $CONTROL_NODEMGR_PORT $DNS_INTROSPECT_PORT $CONTROL_DNS_XMPP_PORT $BGP_PORT "
        ports+="$CONTROLLER_DATABASE_NODEMGR_PORT";;
    "kubernetes")
        ports="$KUBEMANAGER_INTROSPECT_PORT $KUBERNETES_API_PORT";;
    *)
        ports=''
        echo "No proper contrail node type is provided, no iptables will be configured"
        exit 1
esac
echo "Opening ports $ports"

if  is_enabled $CONFIGURE_FIREWALLD; then
  # Configure firewalld rules.
  
  FIREWALL_ZONE=${FIREWALL_ZONE:-'public'}

  echo "$script_name: Configuring firewalld rules to open port/s: [$ports] in zone: [$FIREWALL_ZONE]"

  # Check if the requested zone exists.

  echo "$script_name: Validate that zone [$FIREWALL_ZONE] exists."

  #firewall-cmd --list-all-zones |grep -q $FIREWALL_ZONE

  if ! firewall-cmd --list-all-zones |grep -q $FIREWALL_ZONE; then
    echo "$script_name: Zone [$FIREWALL_ZONE] does not exist."
    echo "$script_name: Exiting with failure."
    exit 1
  fi

  # Deduce the list of ports to be opened/allowed.

  for port in $ports; do
    if grep -q ":" <<< $port ;then  port=${port//:/-};fi
    # Deduce if any rule for this port already exists in the requested zone..
    #firewall-cmd --list-all --zone=$FIREWALL_ZONE | grep -wq $port
    if ! firewall-cmd --list-all --zone=$FIREWALL_ZONE | grep -wq $port; then  
      # No rule targeting this port exists in the requested zone.
      echo "$script_name: Adding rule: firewall-cmd --permanent --zone=$FIREWALL_ZONE --add-port=$port/tcp"

      if ! firewall-cmd --permanent --zone=public --add-port=$port/tcp ; then
        echo "$script_name: ERROR Adding rule: if ! firewall-cmd --permanent --zone=$FIREWALL_ZONE --add-port=$port/tcp ; then"
        echo "$script_name: Exiting with failure."
        exit 1
      fi
    else
      echo "$script_name: A rule for port [$port] exists in the [$FIREWALL_ZONE] zone . Skipping config for this port."
    fi
  done
  firewall-cmd --reload

else
  
  # Configure iptable rules.

  IPTABLES_TABLE=${IPTABLES_TABLE:-'filter'}
  IPTABLES_CHAIN=${IPTABLES_CHAIN:-'INPUT'}

  echo "$script_name: Configuring iptable rules to open port/s: [$ports] in chain: [$IPTABLES_CHAIN] in Table: [$IPTABLES_TABLE]"

  # Check if the requested chain exists.

  echo "$script_name: Validate that chain [$IPTABLES_CHAIN] / table [$IPTABLES_TABLE] exists."

  if ! iptables --list $IPTABLES_CHAIN -t $IPTABLES_TABLE -n ; then
    echo "$script_name: Chain [$IPTABLES_CHAIN] does not exist in table [$IPTABLES_TABLE]"
    echo "$script_name: Exiting with failure."
    exit 1
  fi

  # Deduce the list of ports to be opened/allowed.

  for port in $ports; do

    # Deduce if any rule for this port already exists in the requested chain..

    if ! iptables --list $IPTABLES_CHAIN -t $IPTABLES_TABLE -n | grep -o -E 'dpt:[0-9]+' | cut -f 2 -d ':' | grep -qw $port ; then
      # No rule targeting this port exists in the requested chain.
      echo "$script_name: Adding rule: iptables -t $IPTABLES_TABLE -I $IPTABLES_CHAIN 1 -w 5 -W 100000 -p tcp --dport $port -j ACCEPT"

      if ! iptables -t $IPTABLES_TABLE -I $IPTABLES_CHAIN 1 -w 5 -W 100000 -p tcp --dport $port -j ACCEPT ; then
        echo "$script_name: ERROR Adding rule: iptables -t $IPTABLES_TABLE -I $IPTABLES_CHAIN 1 -w 5 -W 100000 -p tcp --dport $port -j ACCEPT"
        echo "$script_name: Exiting with failure."
        exit 1
      fi
    else
      echo "$script_name: A rule for port [$port] exists in chain [$IPTABLES_CHAIN] table [$IPTABLES_TABLE]. Skipping config for this port."
    fi
  done
fi

