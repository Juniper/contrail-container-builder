#!/bin/bash

function get_default_nic(){
  echo `ip route show | grep "default via" | awk '{print $5}'`
}

function get_listen_ip(){
  default_interface=`get_default_nic`
  default_ip_address=`ip address show dev $default_interface | \
                    head -3 | tail -1 | tr "/" " " | awk '{print $2}'`
  echo ${default_ip_address}
}

function get_server_list(){
  server_typ=$1_NODES
  port_with_delim=$2
  server_list=''
  IFS=',' read -ra server_list <<< "${!server_typ}"
  for server in "${server_list[@]}"; do
    server_address=`echo ${server}`
    extended_server_list+=${server_address}${port_with_delim}
  done
  extended_list="${extended_server_list::-1}"
  echo ${extended_list}
}
