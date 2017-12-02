#!/bin/bash -e

paths_to_remove=""

if [[ "$PACKAGES_URL" =~ http[s]*:// ]] ; then
  # download file if URL is not a local file path
  http_status=$(curl -Isw "%{http_code}" -o /dev/null $PACKAGES_URL)
  if [ $http_status != "200" ]; then
    echo "No Contrail packages found at $PACKAGES_URL"
    exit 1
  fi

  package_fname=$(mktemp /tmp/XXXXXX.rpm)
  echo "Getting $PACKAGES_URL to $package_fname"
  wget -nv -O $package_fname $PACKAGES_URL
  paths_to_remove="$paths_to_remove $package_fname"
else
  package_fname="$PACKAGES_URL"
fi

if [[ "$package_fname" == *rpm ]] ; then
  # unpack packages archive from rpm 
  # script awaits format of rpm file as at build server
  package_dir=$(mktemp -d)
  pushd $package_dir
  rpm2cpio $package_fname | cpio -idmv
  popd
  paths_to_remove="$paths_to_remove $package_dir"
  package_fname="$package_dir/opt/contrail/contrail_packages/contrail_rpms.tgz"
fi

echo "Extract packages to $repo_dir"
tar -xvzf "$package_fname" -C $repo_dir

sudo yum install -y createrepo
pushd $repo_dir
rm -rf repodata
createrepo .
popd

if [[ -n "$paths_to_remove" ]] ; then
  rm -rf $paths_to_remove
fi
