#!/bin/bash -e

# Not checking if status is up because of:
# https://github.com/kubernetes/charts/pull/1227

nodetool status -p ${CASSANDRA_JMX_LOCAL_PORT}
