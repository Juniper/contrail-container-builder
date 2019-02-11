#!/bin/bash -e

# download all requried version of package python-neutron-lbaas
# appropriate version based on OPENSTACK_VERSION will be chosen and installed

mkdir -p /opt/packages
for os_rpm in $(echo $OPENSTACK_EXTRA_RPMS | tr -d '"' | tr ',' ' ') ; do
  echo "INFO: Using $os_rpm"
  yum downgrade -y $os_rpm || /bin/true
  yum upgrade -y $os_rpm || /bin/true
  url=$(repoquery --location python-neutron-lbaas)
  if [[ -z "$url" ]]; then
    echo "ERROR: python-neutron-lbaas couldn't be found in repo $os_rpm"
    exit 1
  fi
  pkg_name=$(basename $url)
  curl -s -o /opt/packages/$basename $url
done
