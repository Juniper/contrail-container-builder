#!/bin/bash

# these next folders must be mounted to compile vrouter.ko in ubuntu: /usr/src /lib/modules

source /common.sh

# Load kernel module
if lsmod | grep -q vrouter; then
  echo "INFO: vrouter.ko already loaded in the system"
  # TODO: handle upgrade
else
  linux=$(awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"')
  echo "INFO: detected linux id: $linux"
  if [[ "$linux" == 'ubuntu' ]]; then
    echo "INFO: Compiling vrouter kernel module for ubuntu..."
    kver=`uname -r`
    echo "INFO: Load kernel module for kver=$kver"
    if [ ! -d "/usr/src/linux-headers-$kver" ] ; then
      echo "ERROR: There is no kernel headers in /usr/src for current kernel. Exiting..."
      exit 1
    fi

    vrouter_full_ver=`dpkg -l contrail-vrouter-dkms | awk '/contrail-vrouter-dkms/{print $3}'`
    vrouter_release_ver=`echo $vrouter_full_ver | cut -d '-' -f 1`
    echo "INFO: detected vrouter version is $vrouter_ver"
    # copy vrouter sources to /usr/src using full version
    mkdir -p /usr/src/vrouter-$vrouter_full_ver
    cp -r /opt/contrail/src/vrouter-$vrouter_release_ver/* /usr/src/vrouter-$vrouter_full_ver
    # and make correct link to correct build
    ln -s /usr/src/vrouter-$vrouter_full_ver /usr/src/vrouter-$vrouter_release_ver
    # build it
    dpkg-reconfigure contrail-vrouter-dkms
    depmod -a
    touch /usr/src/vrouter-$vrouter_full_ver/module_compiled
    modfile="/lib/modules/$kver/updates/dkms/vrouter.ko"
  elif [[ "$linux" == 'centos' ]] ; then
    kver=`uname -r | awk -F "-" '{print $1}'`
    echo "INFO: Load kernel module for kver=$kver"
    modfile=`ls -1rt /opt/contrail/vrouter-kernel-modules/$kver-*/vrouter.ko | tail -1`
  else
    echo "ERROR: Unsupported linux distribution"
    exit 1
  fi

  echo "INFO: Modprobing vrouter $modfile"
  insmod $modfile
  if ! lsmod | grep -q vrouter ; then
    echo "WARNING: Failed to insert vrouter kernel module. Trying to drop caches and insert it again."
    free -h && sync && echo 2 >/proc/sys/vm/drop_caches && free -h
    insmod $modfile
    if ! lsmod | grep -q vrouter ; then
      echo "ERROR: Failed to insert vrouter kernel module"
      exit 1
    fi
  fi
fi

exec $@
