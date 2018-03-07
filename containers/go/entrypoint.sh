#!/bin/bash

source /common.sh

function get_server_json_list(){
  server_typ=$1_NODES
  srv_list=$(echo ${!server_typ} | sed 's/,/'\',\''/g')
  echo "['"$srv_list"']"
}

orchestration_manager=$CLOUD_ORCHESTRATOR

if [[ "$orchestration_manager" == 'kubernetes' ]] ; then
  orchestration_manager='none'
fi

# TODO: Database configuraion
# TODO: TLS Certificate configuraion
# TODO: Proxy
# TODO: KeyStone

cat > /etc/contrail/apisrv.yml << EOM

# Database configuration. Only MySQL supported
database:
    connection: "root:contrail123@tcp(localhost:3306)/contrail_test"
    # Max Open Connections for MySQL Server
    max_open_conn: 100

# Log Level
log_level: debug

# Server configuration
server:
    read_timeout: 10
    write_timeout: 5
    proxy:
        # True for skip backend certificate check
        insecure: false

# Bind addresss
address: ":9091"

# TLS Configuration
tls:
    enabled: true 
    key_file: tools/server.key
    cert_file: tools/server.crt

# Enable GRPC or not
enable_grpc: false 

# Static file config
# key: URL path
# value: file path. (absolute path recommended in production)
static_files:
    public: public

# API Proxy configuration
# key: URL path
# value: String list of backend host
proxy:
    /contrail:
    - http://localhost:8082

noauth: true

# Keystone configuration
# keystone:
#     local: true # Enable local keystone v3. This is only for testing now.
#     assignment:
#         type: static
#         file: tools/keystone.yml
#     store:
#         type: memory
#         expire: 3600
#     authurl: http://localhost:9091/v3
EOM

exec "$@"
