#!/bin/bash

source /functions.sh

#
# Script to configure iptables rules on a node.
#
# This script works off the following environment variables:
#
# IPTABLES_OPEN_PORTS -> Ports to be opened up in iptables, delimited by ','.
#                        Multiple ports or port-ranges may be specified.
#                        Default value is ''
# IPT_CHAIN_NAME      -> Name of the chain in iptables.
#                        This chain, if specified, MUST exist.
#                        Default value is "INPUT"
# IPT_TABLE_NAME      -> Name of the table in iptables.
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

script_name=`basename "$0"`
CONFIGURE=${CONFIGURE_IPTABLES:-'false'}

function configure_iptable_ports_allow_rules() {

  IPT="iptables"
  IPT_TABLE_NAME=${IPTABLES_TABLE:-'filter'}
  IPT_CHAIN_NAME=${IPTABLES_CHAIN:-'INPUT'}
  local dst_port=${IPTABLES_OPEN_PORTS:-''}

  echo "$script_name: Configuring iptable rules to open port/s: [$dst_port] in chain: [$IPT_CHAIN_NAME] in Table: [$IPT_TABLE_NAME]"

  # Check if the requested chain exists.

  echo "$script_name: Validate that chain [$IPT_CHAIN_NAME] / table [$IPT_TABLE_NAME] exists."
  iptables --list $IPT_CHAIN_NAME -t $IPT_TABLE_NAME -n
  if [ $? -ne 0 ]; then
    echo "$script_name: Chain [$IPT_CHAIN_NAME] does not exist in table [$IPT_TABLE_NAME]"
    echo "$script_name: Exiting with failure."
    exit 1
  fi

  # Deduce the list of ports to be opened/allowed.
  local dst_port_list=''
  IFS=',' read -ra dst_port_list <<< "${dst_port}"

  for port in "${dst_port_list[@]}"; do

    # Deduce if any rule for this port already exists in the requested chain..
    iptables --list $IPT_CHAIN_NAME -t $IPT_TABLE_NAME -n | grep -q $port
    local rule_exists=$?

    if  [ $rule_exists  -ne 0 ] ; then
      # No rule targeting this port exists in the requested chain.
      echo "$script_name: Adding rule: $IPT -t $IPT_TABLE_NAME -I $IPT_CHAIN_NAME 1 -w 5 -W 100000 -p tcp --dport $port -j ACCEPT"
      $IPT -t $IPT_TABLE_NAME -I $IPT_CHAIN_NAME 1 -w 5 -W 100000 -p tcp --dport $port -j ACCEPT
      local add_result=$?

      if [ $add_result -ne 0 ]; then
        echo "$script_name: ERROR Adding rule: $IPT -t $IPT_TABLE_NAME -I $IPT_CHAIN_NAME 1 -w 5 -W 100000 -p tcp --dport $port -j ACCEPT"
        echo "$script_name: Exiting with failure."
        exit 1
      fi
    else
      echo "$script_name: A rule for port [$port] exists in chain [$IPT_CHAIN_NAME] table [$IPT_TABLE_NAME]. Skipping config for this port."
    fi
  done

}

# Configure iptable rules if requested.
if is_enabled $CONFIGURE; then
  configure_iptable_ports_allow_rules
fi

exit
