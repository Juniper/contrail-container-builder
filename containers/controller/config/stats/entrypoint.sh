#!/bin/bash -e

source /common.sh

pre_start_init

set_vnc_api_lib_ini

cache_dir=/var/lib/$CONTRAIL_USER

cat > /etc/contrail/contrail-stats-client.conf << EOM
[DEFAULT]
stats_server=${STATS_SERVER:-"http://stats.tungsten.io/api/stats"}
log_file=$LOG_DIR/contrail-stats-client.log
log_level=$LOG_LEVEL
cache=$cache_dir/cache
EOM

mkdir -p $cache_dir
chown -R $CONTRAIL_UID:$CONTRAIL_GID $cache_dir

run_service "$@"
