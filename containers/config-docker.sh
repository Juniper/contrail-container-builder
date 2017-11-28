#!/bin/bash
# Internal script. Configures docker. Takes CONTRAIL_REGISTRY from environment.

if [ -n "$CONTRAIL_REGISTRY" ]; then
  address=$(echo $CONTRAIL_REGISTRY | awk -F':' '{print $1}')
  port=$(echo $CONTRAIL_REGISTRY | awk -F':' '{print $2}')
else
  default_interface=`ip route show |grep "default via" | awk '{print $5}'`
  address=`ip address show dev $default_interface | head -3 | tail -1 | tr "/" " " | awk '{print $2}'`
  port=5000
fi

if [ $port -eq 80 ]; then
  remote_address=$address
else
  remote_address=$address':'$port
fi

export OUSER=$(id -un)

sudo -u root /bin/bash << EOS

echo "Allow user "$OUSER" to access docker directly (requires re-login)"
groupadd docker
usermod -aG docker $OUSER

if [ $port -eq 443 ]; then
  :
else
  echo "Allow docker to connect Contrail registry unsecurely"
  cat > /etc/docker/daemon.json << EOJ
{
  "insecure-registries": ["$remote_address"]
}
EOJ
fi

service docker restart

EOS
