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

# VRouter specific code starts here
function pkt_setup () {
    for f in /sys/class/net/$1/queues/rx-*
    do
        q="$(echo $f | cut -d '-' -f2)"
        r=$(($q%32))
        s=$(($q/32))
        ((mask=1<<$r))
        str=(`printf "%x" $mask`)
        if [ $s -gt 0 ]; then
            for ((i=0; i < $s; i++))
            do
                str+=,00000000
            done
        fi
        echo $str > $f/rps_cpus
    done
    ip link set dev $1 up
}

function insert_vrouter() {
    if [ -f /sys/class/net/pkt1/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt1
    fi
    if [ -f /sys/class/net/pkt2/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt2
    fi
    if [ -f /sys/class/net/pkt3/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt3
    fi
    vif --create vhost0 --mac $phys_int_mac
    vif --add $phys_int --mac $phys_int_mac --vrf 0 --vhost-phys --type physical
    vif --add vhost0 --mac $phys_int_mac --vrf 0 --type vhost --xconnect $phys_int
    return 0
}

echo "INFO: ip address show:"
ip address show

IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac"

# Probe vhost0
vrouter_cidr="$(get_cidr_for_nic vhost0)"

if [[ -e /etc/sysconfig/network-scripts/ifcfg-${phys_int} && ! -e /etc/sysconfig/network-scripts/ifcfg-vhost0 ]]; then
    echo "INFO: creating vhost0"
    insert_vrouter
    cp -f /etc/sysconfig/network-scripts/ifcfg-${phys_int} /etc/sysconfig/network-scripts/ifcfg-vhost0
    sed -i "s/${phys_int}/vhost0/g" /etc/sysconfig/network-scripts/ifcfg-vhost0
    sed -ri "/(DEVICE|ONBOOT)/! s/.*/#& commented by contrail/" /etc/sysconfig/network-scripts/ifcfg-${phys_int}
    ifdown ${phys_int}
    ifup ${phys_int}
    ifup vhost0
elif [[ "$vrouter_cidr" == '' ]] ; then
    echo "INFO: creating vhost0"
    vrouter_cidr=$(get_cidr_for_nic $phys_int)
    VROUTER_GATEWAY=${VROUTER_GATEWAY:-$(get_default_gateway_for_nic $phys_int)}
    insert_vrouter

    # TODO: switch off dhcp on phys_int
    echo "INFO: Changing physical interface to vhost in ip table"
    ip link set vhost0 up
    ip address delete $vrouter_cidr dev $phys_int
    ip address add $vrouter_cidr dev vhost0
    if [[ $VROUTER_GATEWAY ]]; then
        echo "INFO: set default gateway"
        ip route add default via $VROUTER_GATEWAY
    fi
else
    echo "INFO: vhost0 is already up"
fi

exec "$@"
