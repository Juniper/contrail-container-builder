#!/bin/bash -e

if [ -n $CONTRAIL_REPOSITORY ]; then
  dir_prefix=$(echo $CONTRAIL_REPOSITORY | awk -F'/' '{print $4}' | sed 's/'$version'$//')
fi
repo_dir="${package_root_dir}/${dir_prefix}${contrail_version}"

tmp=$(mktemp -d)
pushd $tmp
rpm2cpio "$repo_dir/contrail-vrouter-${CONTRAIL_VERSION}.el7.x86_64.rpm" | cpio -idmv
vrouter_ko=`find opt/contrail/vrouter-kernel-modules/ | grep vrouter.ko`
cp $vrouter_ko "${repo_dir}/"
popd
rm -rf $tmp
