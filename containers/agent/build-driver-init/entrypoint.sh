#!/bin/bash -x

# these next folders must be mounted to compile vrouter.ko in ubuntu: /usr/src /lib/modules

echo "INFO: Compiling vrouter kernel module for ubuntu..."
kver=`uname -r`
echo "INFO: Detected kernel version is $kver"
# TODO: pass or detect it here
contrail_version="5.0.0"
echo "INFO: use vrouter version $contrail_version"

if [ ! -d "/usr/src/linux-headers-$kver" ] ; then
  echo "ERROR: There is no kernel headers in /usr/src for current kernel. Exiting..."
  exit 1
fi

vrouter_dir="/usr/src/vrouter-${contrail_version}"
mkdir -p $vrouter_dir
pushd $vrouter_dir
tar -xf /opt/contrail/src/modules/contrail-vrouter/contrail-vrouter-${contrail_version}.tar.gz
popd

templ=$(cat /opt/contrail/src/dkms.conf)
content=$(eval "echo \"$templ\"")
echo "$content" > $vrouter_dir/dkms.conf

dkms add -m vrouter -v "${contrail_version}"
dkms build -m vrouter -v "${contrail_version}"
dkms install -m vrouter -v "${contrail_version}"
depmod -a

# check vrouter.ko was built
ls -l /lib/modules/$kver/updates/dkms/vrouter.ko

touch $vrouter_dir/module_compiled
