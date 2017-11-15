#!/bin/bash

function wait_for_contrail_api() {
  # TODO: wait for correct contrail API address.
  for (( i=0; i<120; i++)) ; do
    # TODO: check only one port depending on input params
    # 8095 is used when cloud_orchestrator == openstack and aaa-mode != no-auth
    if curl -sI http://127.0.0.1:8095/ | head -1 | grep -q 200 ; then
      echo "INFO $(date): API server is ready."
      return
    # 8082 in other cases
    elif curl -sI http://127.0.0.1:8082/ | head -1 | grep -q 200 ; then
      echo "INFO $(date): API server is ready."
      return
    fi
    echo "INFO $(date): waiting for API server: $i / 120"
    sleep 1
  done
  echo "ERROR $(date): Config API server is not responding. Exiting..."
  exit 1
}

function get_server_list() {
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
