  #!/bin/bash -x

default_pkgs="apt,procps,util-linux,systemd"

pkgs=${1:-${default_pkgs}}
echo "INFO: Upgrade $pkgs"

DEBIAN_FRONTEND=noninteractive
apt-get update || /bin/true
apt-get upgrade -y --no-install-recommends ${pkgs//,/ }
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
