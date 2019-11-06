#!/bin/bash -e
# Sets up node for building containers. Parses common.env to get parameters (CONTRAIL_VERSION, CONTRAIL_REGISTRY,
# CONTRAIL_REPOSITORY) or take them from environment.
# It installs http server, creates directory with rpm packages taken from PAKAGES_URL, install docker,
# installs docker-registry.

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../parse-env.sh"

echo 'Build platform: '$LINUX_ID:$LINUX_VER_ID
echo 'Target platform: '$LINUX_DISTR:$LINUX_DISTR_VER
echo 'Contrail container tag: '$CONTRAIL_CONTAINER_TAG
echo 'Contrail registry: '$CONTRAIL_REGISTRY
echo 'Contrail repository: '$CONTRAIL_REPOSITORY

if [[ "$LINUX_ID" == 'rhel' ]] ; then
  sudo -E $DIR/rhel-prepare-system.sh
fi

sudo -u root /bin/bash << EOS
if [[ "$LINUX_ID" == 'ubuntu' ]] ; then
  apt-get -y install rsync
else
  yum install -y rsync
fi
EOS

# Define global variables
export package_root_dir="/var/www"

# TODO: do not download/install rpm repository if CONTRAIL_REPOSITORY is defined.
if [[ -n "$CONTRAIL_REPOSITORY" ]]; then
  dir_prefix=$(echo $CONTRAIL_REPOSITORY | awk -F'/' '{print $4}' | sed 's/'$CONTRAIL_CONTAINER_TAG'$//')
fi
export repo_dir="${package_root_dir}/${dir_prefix}${CONTRAIL_CONTAINER_TAG}"
if [ -d $repo_dir ]; then
  echo 'Remove existing packages in '$repo_dir
  sudo rm -rf $repo_dir
fi
sudo mkdir -p $repo_dir
sudo chown -R $USER $repo_dir

source "$DIR/install-http-server.sh"
$DIR/install-repository.sh

$DIR/validate-docker.sh

# TODO: do not installs local registry if external is provided.
$DIR/install-registry.sh

sudo -u root /bin/bash << EOS
if [[ "$LINUX_ID" == 'ubuntu' ]] ; then
  # Stop firewall
  echo 'INFO: disable firewall'
  service ufw stop || echo 'WARNING: failed to stop firewall service'
  systemctl disable ufw || echo 'WARNING: failed to disable firewall'
else
  # Disable selinux
  echo 'INFO: disable selinux'
  setenforce 0 || echo 'WARNING: setenforce 0 failed, selinux is probably already disabled'
  if [ -f ./config ] && grep -q "^[ ]*SELINUX[ ]*=" ./config ; then
    sed -i 's/^[ ]*SELINUX[ ]*=.*$/SELINUX=permissive/g' /etc/selinux/config
  else
    echo 'SELINUX=permissive' >> /etc/selinux/config
  fi
  # Stop firewall
  echo 'INFO: disable firewall'
  service firewalld stop || echo 'WARNING: failed to stop firewall service'
  chkconfig firewalld off || echo 'WARNING: failed to disable firewall'
fi
iptables -F || echo 'WARNING: failed to flush iptables rules'
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
EOS
