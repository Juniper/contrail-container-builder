#!/bin/bash
# Configures insecure registry for test registry server. Takes CONTRAIL_REGISTRY and CONTRAIL_TEST_REGISTRY from environment.

if [ -n "$CONTRAIL_TEST_REGISTRY" ] && [ "$CONTRAIL_TEST_REGISTRY" != "$CONTRAIL_REGISTRY" ]; then
  address=$(echo $CONTRAIL_TEST_REGISTRY | awk -F':' '{print $1}')
  port=$(echo $CONTRAIL_TEST_REGISTRY | awk -F':' '{print $2}')

  if [ $port -eq 80 ]; then
    remote_address=$address
  else
    remote_address=$address':'$port
  fi

  sudo -u root /bin/bash << EOS

if [ $port -eq 443 ]; then
    :
else
    echo "Allow docker to connect Contrail test registry insecurely"
    sed -ie 's/insecure-registries\(.*\)]/insecure-registries\1, \"'$remote_address'\"]/' /etc/docker/daemon.json
    service docker restart
fi
EOS
fi
