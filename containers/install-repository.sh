#!/bin/bash -e

# Internal script. Prepares RPM repository.
# If $CONTRAIL_INSTALL_PACKAGES_URL is started from URL then it's downloaded to temporary dir.
# If extension of file pointed by $CONTRAIL_INSTALL_PACKAGES_URL is rpm then it's treated as
# package with .tgz file inside (structure of rpm package equals to Junper's one)
# Then .tgz archive is unpacked by script to specific folder in /var/www/ directory.
# In the specific folder repodata is built by the script.

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

paths_to_remove=""

if [[ "$CONTRAIL_INSTALL_PACKAGES_URL" =~ http[s]*:// ]] ; then
  # download file if URL is not a local file path
  http_status=$(curl -Isw "%{http_code}" -o /dev/null $CONTRAIL_INSTALL_PACKAGES_URL)
  if [ $http_status != "200" ]; then
    echo "No Contrail packages found at $CONTRAIL_INSTALL_PACKAGES_URL"
    exit 1
  fi

  temp_dir=$(mktemp -d)
  pushd $temp_dir
  echo "Getting $CONTRAIL_INSTALL_PACKAGES_URL to $temp_dir"
  wget -nv $CONTRAIL_INSTALL_PACKAGES_URL
  # only one file will be there
  package_fname="$temp_dir/`ls`"
  popd
  paths_to_remove="$paths_to_remove $temp_dir"
else
  package_fname="$CONTRAIL_INSTALL_PACKAGES_URL"
fi

case $package_fname in
  *rpm)
    # unpack packages archive from rpm
    # script awaits format of rpm file as at build server
    temp_dir=$(mktemp -d)
    pushd $temp_dir
    rpm2cpio $package_fname | cpio -idmv
    popd
    paths_to_remove="$paths_to_remove $temp_dir"
    package_fname="$temp_dir/opt/contrail/contrail_packages/contrail_rpms.tgz"
    ;;
  *deb)
    echo "INFO: it is expected that for deb packages tgz archive is provided"
    ;;
esac

echo "Extract packages to $repo_dir"
tar -xvzf "$package_fname" -C $repo_dir

# prepare repo
pushd $repo_dir
rm -rf repodata
createrepo .
popd

if [[ -n "$paths_to_remove" ]] ; then
  rm -rf $paths_to_remove
fi
