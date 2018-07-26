#!/bin/bash -e

if [ -z "$REDIS_SERVER_PASSWORD" ];then
    redis-server --bind "$IPFABRIC_SERVICE_HOST" 127.0.0.1\
                 --protected-mode yes\
                 --lua-time-limit 15000\
                 --dbfilename ""
else
    redis-server --bind "$IPFABRIC_SERVICE_HOST" 127.0.0.1\
                 --protected-mode yes\
                 --lua-time-limit 15000\
                 --requirepass "$REDIS_SERVER_PASSWORD"\
                 --dbfilename ""
fi
