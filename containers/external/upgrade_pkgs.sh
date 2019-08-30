  #!/bin/bash -x

set -x

default_pkgs="apt,procps,util-linux,libtasn1-6"

pkgs=${1:-${default_pkgs}}
echo "INFO: Upgrade $pkgs"
pkgs=$(echo $pkgs | tr ',' ' ')

export DEBIAN_FRONTEND=noninteractive
apt-get update || /bin/true
for p in $pkgs ; do
  dpkq-query -s $p && apt-get upgrade -y --no-install-recommends $p
done
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/* || /bin/true
