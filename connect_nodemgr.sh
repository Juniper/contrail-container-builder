#!/bin/bash -x


id=$(docker ps | awk '/nodemgr/ {print ($1)}')

docker exec -it $id bash

