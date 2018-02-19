#!/bin/bash

source /common.sh
source /agent-functions.sh

TRACK_VHOST0_PAUSE=${TRACK_VHOST0_PAUSE:-5}

while (true) ; do

    echo "INFO: ip address show:"
    ip address show

    if init_vhost0 ; then
        break
    fi

    echo "INFO: wait for $TRACK_VHOST0_PAUSE seconds..."
    sleep $TRACK_VHOST0_PAUSE
done

exec $@
