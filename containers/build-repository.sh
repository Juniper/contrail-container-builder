#!/bin/bash -e

echo "INFO: BUILD_PACKAGES is true - run build..."
# all paths are hardcoded here...
$HOME/contrail-build-poc/build.sh

cp $HOME/rpmbuild/RPMS/x86_64/*.rpm $repo_dir/
cp $HOME/rpmbuild/RPMS/noarch/*.rpm $repo_dir/
pushd $repo_dir
sudo yum install -y createrepo
sudo createrepo .
popd
