#!/bin/bash

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
