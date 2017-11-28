#!/bin/bash -e
# Internal script, used to build packages from source-code. Used instead of install-repository.sh script by setup-for-build.sh

echo "INFO: BUILD_PACKAGES is true - run build..."
# all paths are hardcoded here...
$HOME/contrail-build-poc/build.sh

cp $HOME/rpmbuild/RPMS/x86_64/*.rpm $repo_dir/
cp $HOME/rpmbuild/RPMS/noarch/*.rpm $repo_dir/
pushd $repo_dir
sudo yum install -y createrepo
sudo createrepo .
popd
