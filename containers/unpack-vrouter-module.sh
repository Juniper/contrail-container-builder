#!/bin/bash -e

tmp=$(mktemp -d)
pushd $tmp
rpm2cpio "$repo_dir/contrail-vrouter-${CONTRAIL_VERSION}.el7.x86_64.rpm" | cpio -idmv
vrouter_ko=`find opt/contrail/vrouter-kernel-modules/ | grep vrouter.ko`
cp $vrouter_ko "${repo_dir}/"
popd
rm -rf $tmp
