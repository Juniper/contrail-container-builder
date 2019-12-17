#!/bin/bash -x

# these next folders must be mounted to compile vrouter.ko in ubuntu: /usr/src /lib/modules

echo "INFO: Compiling vrouter kernel module for ubuntu..."
kver=`uname -r`
echo "INFO: Detected kernel version is $kver"

if [ ! -f "/contrail_version" ] ; then
  echo "ERROR: There is no version specified in /contrail_version file. Exiting..."
  exit 1
fi
contrail_version="$(cat /contrail_version)"
echo "INFO: use vrouter version $contrail_version"

if [ ! -d "/usr/src/linux-headers-$kver" ] ; then
  echo "ERROR: There is no kernel headers in /usr/src for current kernel. Exiting..."
  exit 1
fi
if [[ -e /opt/contrail/src/modules/contrail-vrouter/contrail-vrouter-${contrail_version}.tar.gz ]] ; then
  vrouter_dir="/usr/src/vrouter-${contrail_version}"
  mkdir -p $vrouter_dir
  pushd $vrouter_dir
  tar -xf /opt/contrail/src/modules/contrail-vrouter/contrail-vrouter-${contrail_version}.tar.gz
  popd
else
  vrouter_dir="/usr/src/vrouter"
fi


templ=$(cat /opt/contrail/src/dkms.conf)
content=$(eval "echo \"$templ\"")
echo "$content" > $vrouter_dir/dkms.conf

mkdir -p /vrouter/${contrail_version}/build/include/
mkdir -p /vrouter/${contrail_version}/build/dp-core
dkms --verbose add -m vrouter -v "${contrail_version}"
dkms --verbose build -m vrouter -v "${contrail_version}"
cat /var/lib/dkms/vrouter/${contrail_version}/build/make.log
dkms --verbose install -m vrouter -v "${contrail_version}"
depmod -a

# check vrouter.ko was built
ls -l /lib/modules/$kver/updates/dkms/vrouter.ko || exit 1

touch $vrouter_dir/module_compiled

# copy vif util to host
if [[ -d /host/bin && ! -f /host/bin/vif ]] ; then
    /bin/cp -f /contrail_tools/usr/bin/vif /host/bin/vif
    chmod +x /host/bin/vif
fi
