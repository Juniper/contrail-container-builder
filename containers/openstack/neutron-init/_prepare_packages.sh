#!/bin/bash -ex

# download all requried version of package python-neutron-lbaas
# appropriate version based on OPENSTACK_VERSION will be chosen and installed at runtime

if [[ "$LINUX_DISTR" =~ 'rhel' || "$LINUX_DISTR" =~ 'ubi' ]]; then
  # RedHat has own packages installed in neutron container - do not store it for RHEL
  exit 0
fi

pkd_dir="/opt/packages"
mkdir -p $pkd_dir
for version in newton ocata queens rocky stein; do
  echo "INFO: Using $version"
  url=$(repoquery --location python-neutron-lbaas-${version})
  if [[ -z "$url" ]]; then
    echo "ERROR: python-neutron-lbaas-$version couldn't be found in repo but it must be present somewhere."
    exit 1
  fi
  pkg_name=$(basename $url)
  curl -s -o $pkd_dir/$pkg_name $url
done
