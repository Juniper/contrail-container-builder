#!/bin/bash
if [[ -n ${B} ]]; then
  cd contrail-ansible-deployer
  git checkout -b ${B}
  if [[ -n ${CP} ]]; then
    git config --global user.email "contrail@juniper.net"
    git config --global user.name "Contrail Deployer"
    git fetch https://review.opencontrail.org/Juniper/contrail-ansible-deployer refs/changes/${CP} && git cherry-pick FETCH_HEAD
  fi
fi
if [[ ! -d /configs ]]; then
  mkdir /configs
fi
if [[ $config ]]; then
  printenv $config > /instances.yaml
fi
echo "[defaults]" > /etc/ansible/ansible.cfg
echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
exec "$@"
