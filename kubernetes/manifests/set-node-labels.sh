#!/bin/bash
# Sets labels to kubernetes nodes accordingly nodes lists in common.env (CONTROLLER_NODES, AGENT_NODES, ...) - pods will be
# assigned to correpondingly labeled nodes.
# Looks to KUBERNETES_NODES_MAP from common.env if it's configured in case of multi-card nodes deployment to determine which
# IP address to look for in nodes lists. If it's not configured the IPs to look for in nodes lists are taken from kubernetes.

label_prefix="node-role.opencontrail.org/"

declare -a pod_types=( CONFIG CONTROL WEBUI ANALYTICS AGENT CONFIGDB ANALYTICSDB ANALYTICS_ALARM ANALYTICS_SNMP)

manifest_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$manifest_dir" ]]; then manifest_dir="$PWD"; fi
source "$manifest_dir/../../parse-env.sh"

fill_map() {
  local _resultvar=$1
  local _data=$2
  local -a _list
  readarray _list <<< "$_data"
  for _el in "${_list[@]}"; do
    read _name _values <<< $_el
    eval $_resultvar[${_name}]=${_values}
  done
}

data=`kubectl get nodes --show-labels | tail -n +2 | awk '{print $1" "$5}'`
declare -A node_labels
fill_map node_labels "$data"

if [[ "${#KUBERNETES_NODES_MAP[@]}" != "0" ]]; then
  eval $(typeset -A -p KUBERNETES_NODES_MAP|sed 's/ KUBERNETES_NODES_MAP=/ node_ips=/')
else
  data=`kubectl get nodes -o custom-columns="NAME:.metadata.name, IP:.status.addresses[?(@.type==\"InternalIP\")].address" | tail -n +2`
  declare -A node_ips
  fill_map node_ips "$data"
fi

check_specified_ips() {
  local _type=${1,,}
  local _nodes=${_type^^}_NODES
  IFS="," read -ra _ips <<< "${!_nodes}"
  if [[ "${#_ips[@]}" == "0" ]]; then
    echo "ERROR: No IP is specified for $_type in var $_nodes = '${!_nodes}'"
  else
    for _ip in ${_ips[@]}; do
      if ! [[ "${node_ips[@]}" =~ "${_ip}" ]]; then
        echo "ERROR: Cannot find Kubernetes node for $_ip specified in $_nodes = '${!_nodes}' (node_ips: ${node_ips[@]})"
      fi
    done
  fi
}

update_node_label() {
  local _pod_type=${1,,}
  local _nodes=${_pod_type^^}_NODES
  local _label=${label_prefix}${_pod_type}
  for _node in "${!node_ips[@]}"; do
    if [[ "${!_nodes}" =~ "${node_ips[${_node}]}" ]]; then
      if [[ "${node_labels[${_node}]}" =~ "${_label}=" ]]; then
        echo $_node is already labeled for $_pod_type
      else
        echo Set label on $_node for $_pod_type
        kubectl label node ${_node} ${_label}=
      fi
    else
      if [[ "${node_labels[${_node}]}" =~ "${_label}=" ]]; then
        echo Remove label from $_node for $_pod_type
        kubectl label node ${_node} ${_label}-
      else
        echo $_node is already not labeled for $_pod_type
      fi
    fi
  done
}

for _type in ${pod_types[@]}; do
  check_specified_ips $_type
  update_node_label $_type
done
