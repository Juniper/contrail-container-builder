#!/bin/bash

echo "INFO: copy Contrail starter scripts to starter volume /opt/contrail/"
cp /*.sh /opt/contrail/

exec "$@"
