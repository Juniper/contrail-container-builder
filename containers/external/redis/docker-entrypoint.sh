#!/bin/sh
set -ex
source /common.sh
source /functions.sh
# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
	set -- redis-server "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'redis-server' -a "$(id -u)" = '0' ]; then
	find . \! -user redis -exec chown redis '{}' +
	CONTRAIL_UID=$( id -u redis )
	CONTRAIL_GID=$( id -g redis )

	do_run_service "$@"
fi

CONTRAIL_UID=$( id -u redis )
CONTRAIL_GID=$( id -g redis )

do_run_service "$@"
