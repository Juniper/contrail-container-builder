#!/bin/bash -x

# replace this path with actual nodemgr
src=$HOME/extern/git/cloudscaling/contrail-controller/src/nodemgr

id=$(docker ps | awk '/nodemgr/ {print $1}')
docker cp ${src} ${id}:/root/
docker exec $id chown -R root:root /root/nodemgr
docker exec $id cp -r /usr/lib/python2.7/site-packages/nodemgr /root/nodemgr.org
docker exec $id bash -c "/usr/bin/yes | cp -r /root/nodemgr /usr/lib/python2.7/site-packages/"

