#!/bin/bash -e

source /common.sh

pre_start_init

stats_data=/var/lib/stats
mkdir -p $stats_data
chown -R $CONTRAIL_UID:$CONTRAIL_GID $stats_data

mkdir -p /etc/contrail
cat > /etc/contrail/contrail-stats-client.conf << EOM
[DEFAULT]
stats_server=${STATS_SERVER:-"http://stats.tungsten.io/api/stats"}
log_file=$CONTAINER_LOG_DIR/contrail-stats-client.log
log_level=$LOG_LEVEL
state=$stats_data/state
EOM

add_ini_params_from_env STATS /etc/contrail/contrail-stats-client.conf

set_vnc_api_lib_ini

run_service "$@"
