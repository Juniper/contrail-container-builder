#!/bin/bash -e
# Internal script, used to build packages from source-code. Used instead of install-repository.sh script by setup-for-build.sh

echo "INFO: BUILD_PACKAGES is true - run build..."
# all paths are hardcoded here...
$HOME/contrail-build-poc/build.sh

sudo yum install -y createrepo

cp $HOME/rpmbuild/RPMS/x86_64/*.rpm $repo_dir/
cp $HOME/rpmbuild/RPMS/noarch/*.rpm $repo_dir/
pushd $repo_dir
wget -nv https://s3-us-west-2.amazonaws.com/contrailrhel7/third-party-packages.tgz
tar -xf third-party-packages.tgz
rm third-party-packages.tgz
createrepo .
popd
