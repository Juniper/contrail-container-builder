#!/bin/bash -e

source /common.sh

pre_start_init

set_vnc_api_lib_ini

cat > /etc/contrail/contrail-stats-client.conf << EOM
[DEFAULT]
stats_server=${STATS_SERVER:-"http://stats.tungsten.io/api/stats"}
log_file=$LOG_DIR/contrail-stats-client.log
log_level=$LOG_LEVEL
EOM

add_ini_params_from_env STATS_SERVER /etc/contrail/contrail-stats-client.conf

exec "$@"

