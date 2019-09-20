#!/bin/bash -e

source /common.sh

pre_start_init

set_vnc_api_lib_ini

stats_data=/var/lib/stats

cat > /etc/contrail/contrail-stats-client.conf << EOM
[DEFAULT]
stats_server=${STATS_SERVER:-"http://stats.tungsten.io/api/stats"}
log_file=$LOG_DIR/contrail-stats-client.log
log_level=$LOG_LEVEL
state=$stats_data/state
EOM

add_ini_params_from_env STATS /etc/contrail/contrail-stats-client.conf

mkdir -p $stats_data
chown -R $CONTRAIL_UID:$CONTRAIL_GID $stats_data

run_service "$@"
