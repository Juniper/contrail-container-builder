#!/bin/bash -ex
# Internal script. Extracts vrouter.ko kernel module and puts it into www server root.
# Takes CONTRAIL_VERSION and repo_dir from environment.

tmp=$(mktemp -d)
pushd $tmp
vrouter_rpm=`find "$repo_dir/" | grep "contrail-vrouter-${CONTRAIL_VERSION}-${OPENSTACK_VERSION}.el7"`
rpm2cpio "$vrouter_rpm" | cpio -idmv
vrouter_ko=`find opt/contrail/vrouter-kernel-modules/ | grep vrouter.ko`
cp $vrouter_ko "${repo_dir}/"
popd
rm -rf $tmp
