#!/bin/bash -ex

if [ -n $CONTRAIL_REPOSITORY ]; then
  dir_prefix=$(echo $CONTRAIL_REPOSITORY | awk -F'/' '{print $4}' | sed 's/'$CONTRAIL_VERSION'$//')
fi
repo_dir="${package_root_dir}/${dir_prefix}${CONTRAIL_VERSION}"

tmp=$(mktemp -d)
pushd $tmp
vrouter_rpm=`find "$repo_dir/" | grep "contrail-vrouter-${CONTRAIL_VERSION}.el7"`
rpm2cpio "$vrouter_rpm" | cpio -idmv
vrouter_ko=`find opt/contrail/vrouter-kernel-modules/ | grep vrouter.ko`
cp $vrouter_ko "${repo_dir}/"
popd
rm -rf $tmp
