#!/bin/bash
if [[ -n ${B} ]]; then
  cd contrail-command-deployer
  git checkout ${B}
  if [[ -n ${CP} ]]; then
    git config --global user.email "contrail@juniper.net"
    git config --global user.name "Contrail Deployer"
    git fetch https://review.opencontrail.org/Juniper/contrail-command-deployer refs/changes/${CP} && git cherry-pick FETCH_HEAD
  fi
fi
if [[ $config ]]; then
  printenv $config > /command_servers.yaml
fi
if [[ $cluster_config ]]; then
  printenv $cluster_config > /instances.yaml
fi
echo "[defaults]" > /etc/ansible/ansible.cfg
echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
exec "$@"
