#!/bin/bash -e

source /common.sh

pre_start_init

export STATS_SERVER=https://tungsten.io:8000/api/stats

set_third_party_auth_config
set_vnc_api_lib_ini

cat > /etc/contrail/contrail-stats-client.conf << EOM
[LOGGING]
log_file=$LOG_DIR/contrail-stats-client.log
log_level=SYS_INFO
EOM

add_ini_params_from_env STATS_CLIENT /etc/contrail/contrail-stats-client.conf

/usr/bin/python /usr/bin/contrail-stats-client --config /etc/contrail/contrail-stats-client.conf

