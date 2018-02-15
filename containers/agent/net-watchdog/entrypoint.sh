#!/bin/bash

source /common.sh
source /agent-functions.sh

TRACK_VHOST0=${TRACK_VHOST0:-'true'}
TRACK_VHOST0_PAUSE=${TRACK_VHOST0_PAUSE:-5}

while (true) ; do

    echo "INFO: ip address show:"
    ip address show

    init_vhost0

    if [[ "$TRACK_VHOST0" != 'true' ]] ; then
        echo "INFO: TRACK_VHOST0 is $TRACK_VHOST0. Stop stracking."
        break
    fi
    echo "INFO: wait for $TRACK_VHOST0_PAUSE seconds..."
    sleep $TRACK_VHOST0_PAUSE
done

exec $@
