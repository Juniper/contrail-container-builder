#!/bin/bash

source /common.sh

## Add agent configs here

taskset_param=${taskset_param:-''}
############################################################################

## vRouter/DPDK Functions
############################################################################

_is_ubuntu_xenial() {
    $(ls -al /etc/lsb-release > /dev/null 2>&1 && \
      cat /etc/lsb-release | grep -i xenial > /dev/null 2>&1)
    return $?
}

##
## Read Agent Configuration File and Global vRouter/DPDK Configuration
##
_dpdk_conf_read() {
    if [ -n "${_DPDK_CONF_READ}" ]; then
        return
    fi
    _DPDK_CONF_READ=1

    ## global vRouter/DPDK configuration
    DPDK_BINDING_DRIVER_DATA='/var/run/vrouter'
    DPDK_BIND="/opt/contrail/bin/dpdk_nic_bind.py"
    DPDK_RTE_CONFIG="/run/.rte_config"
    DPDK_NETLINK_TCP_PORT=20914
    DPDK_MEM_PER_SOCKET="1024"

    PLATFORM=$AGENT_PLATFORM
    DPDK_PHY=$PHYSICAL_INTERFACE
    DPDK_PHY_MAC=$(get_iface_mac $DPDK_PHY)
    DPDK_VHOST="vhost0"
    DPDK_UIO_DRIVER=$DPDK_UIO_DRIVER
    DPDK_PHY_ADDRESS=$(get_cidr_for_nic $DPDK_PHY)
    DPDK_PHY_GATEWAY=$VROUTER_GATEWAY
    is_interface_vlan="$(is_interface_vlan ${DPDK_PHY})"
    if [[ "$is_interface_vlan" == '' ]] ; then
        DPDK_PHY="$(get_physical_interface_of_vlan ${DPDK_PHY})"
    fi

    DPDK_PHY_PCI="$(get_pci_address_of_interface ${DPDK_PHY})"

    if [ -z "${DPDK_UIO_DRIVER}" ]; then
        if _is_ubuntu_xenial; then
            DPDK_UIO_DRIVER="uio_pci_generic"
        else
            DPDK_UIO_DRIVER="igb_uio"
        fi
    fi

    if [ -z "${DPDK_PHY}" ]; then
        echo "$(date): Error reading dpdk physical device, not  defined"
        exit 1
    fi
    if [ -z "${DPDK_VHOST}" ]; then
        echo "$(date): Error: no vhost device defined"
        exit 1
    fi

    # TODO: Remove this waiting loop as the _dpdk_conf_read() is used also when
    # the vRouter is already started. In that case, there is no entry under
    # /sys/class/net/${DPDK_PHY} and this code unnecessarily adds 20s of a
    # delay, enlarging the start/stop time of the supervisor-vrouter service.
    loops=0
    # Waiting for interface, we should wait
    # for interface in case of rebinding interface from UIO driver to kernel driver
    while [ ! -e /sys/class/net/${DPDK_PHY} ]
    do
        sleep 2
        loops=$(($loops + 1))
        if [ $loops -ge 10 ]; then
            echo "$(date): ${DPDK_PHY} interface: Does not exist."
            return 1
        fi
    done

    ## check for VLANs
    _vlan_file="/proc/net/vlan/${DPDK_PHY}"
    DPDK_VLAN_IF=""
    DPDK_VLAN_ID=""
    DPDK_VLAN_DEV=""
    if [ -f "${_vlan_file}" ]; then
        DPDK_VLAN_IF="${DPDK_PHY}"
        DPDK_VLAN_ID=`cat ${_vlan_file} | grep "VID:" | head -1 | awk '{print $3}'`
        DPDK_VLAN_DEV=`cat ${_vlan_file} | grep "Device:" | head -1 | awk '{print $2}'`
        if [ -n "${DPDK_VLAN_DEV}" ]; then
            ## use raw device and pass VLAN ID as a parameter
            DPDK_PHY="${DPDK_VLAN_DEV}"
        fi
    fi
}

##
## Check if vRouter/DPDK is Running
##
_is_vrouter_dpdk_running() {
    # check for NetLink TCP socket
    lsof -ni:${DPDK_NETLINK_TCP_PORT} -sTCP:LISTEN > /dev/null

    return $?
}

##
## Start vRouter/DPDK
##
vrouter_dpdk_start() {
    echo "$(date): Starting vRouter/DPDK..."

    _dpdk_conf_read

    # remove rte configuration file if vRouter has crashed
    rm -f ${DPDK_RTE_CONFIG}

    # set maximum socket buffer size to (max hold flows entries * 9160 bytes)
    sysctl -w net.core.wmem_max=9160000

    loops=0
    # wait for vRouter/DPDK to start
    while ! _is_vrouter_dpdk_running
    do
        sleep 5
        loops=$(($loops + 1))
        if [ $loops -ge 60 ]; then
            echo "$(date): Error starting ${VROUTER_SERVICE} service: vRouter/DPDK is not running"
            return 1
        fi
    done

    # Include huge pages in core dump of contrail-vrouter-dpdk process
    pid=$(pidof contrail-vrouter-dpdk)
    if [ -f /proc/$pid/coredump_filter ]; then
            cdump_filter=`cat /proc/$pid/coredump_filter`
            cdump_filter=$((0x40 | 0x$cdump_filter))
            echo $cdump_filter > /proc/$pid/coredump_filter
    else
            cdump_filter=0x73
            echo $cdump_filter > /proc/$pid/coredump_filter
    fi

    echo "$(date): Waiting for Agent to configure ${DPDK_VHOST}..."
    loops=0
    while [ ! -L /sys/class/net/${DPDK_VHOST} ]
    do
        sleep 2
        loops=$(($loops + 1))
        if [ $loops -ge 10 ]; then
            echo "$(date): Error Agent configuring ${DPDK_VHOST}: interface does not exist"
            break
        fi
    done

    # check if vhost0 is not present, then create vhost0 and $dev
    if [ ! -L /sys/class/net/${DPDK_VHOST} ]; then
        echo "$(date): Creating ${DPDK_VHOST} interface with vif utility..."

        if [ -z "${DPDK_PHY_MAC}" ]; then
            echo "Error reading ${AGENT_CONF}: physical MAC address is not defined"
            return 1
        fi
        if [ -z "${DPDK_PHY_PCI}" ]; then
            echo "Error reading ${AGENT_CONF}: physical PCI address is not defined"
            return 1
        fi

        echo "$(date): Adding ${DPDK_PHY} interface with vif utility..."
        # add DPDK ethdev 0 as a physical interface
        vif --add 0 --mac ${DPDK_PHY_MAC} --vrf 0 --vhost-phys --type physical --pmd --id 0
        if [ $? != 0 ]; then
            echo "$(date): Error adding ${DPDK_PHY} interface"
        fi

        echo "$(date): Adding ${DPDK_VHOST} interface with vif utility..."
        # TODO: vif --xconnect seems does not work without --id parameter?
        vif --add ${DPDK_VHOST} --mac ${DPDK_PHY_MAC} --vrf 0 --type vhost --xconnect 0 --pmd --id 1
        if [ $? != 0 ]; then
            echo "$(date): Error adding ${DPDK_VHOST} interface"
        fi
    fi

    # For redhat, bringup vhost0 and set MAC address
    if [ -f /etc/redhat-release ]; then
        ifup ${DPDK_VHOST}
        ifconfig ${DPDK_VHOST} hw ether ${DPDK_PHY_MAC}
    fi

    # Bring up vhost0
    ip address add ${DPDK_PHY_ADDRESS} dev ${DPDK_VHOST} && ip link set dev ${DPDK_VHOST} up
    ip route add default via ${DPDK_PHY_GATEWAY} dev ${DPDK_VHOST}
    echo "$(date): Done starting vRouter/DPDK."
    return 0
}

##
## Collect Runtime Bond Device Information
## Returns:
##     DPDK_BOND_MODE   - non-empty string for bond interface, empty otherwise
##     DPDK_BOND_SLAVES - list of bond device members or just one non-bond device
##
_dpdk_system_bond_info_collect() {
    if [ -n "${_DPDK_SYSTEM_BOND_INFO_COLLECT}" ]; then
        return
    fi
    _DPDK_SYSTEM_BOND_INFO_COLLECT=1

    _dpdk_conf_read

    bond_dir="/sys/class/net/${DPDK_PHY}/bonding"
    DPDK_BOND_MODE=""
    DPDK_BOND_POLICY=""
    DPDK_BOND_SLAVES=""
    if [ -d ${bond_dir} ]; then
        DPDK_BOND_MODE=`cat ${bond_dir}/mode | awk '{print $2}'`
        DPDK_BOND_POLICY=`cat ${bond_dir}/xmit_hash_policy | awk '{print $1}'`
        DPDK_BOND_SLAVES=`cat ${bond_dir}/slaves | tr ' ' '\n' | sort | tr '\n' ' '`
        DPDK_BOND_SLAVES="${DPDK_BOND_SLAVES% }"
    else
        # put the physical interface into the list, so we can use the
        # same code to bind/unbind the interface
        DPDK_BOND_SLAVES="${DPDK_PHY}"
    fi

    ## Map Linux values to DPDK
    case "${DPDK_BOND_POLICY}" in
        "layer2") DPDK_BOND_POLICY="l2";;
        "layer3+4") DPDK_BOND_POLICY="l34";;
        "layer2+3") DPDK_BOND_POLICY="l23";;
        # DPDK 2.0 does not support inner packet hashing
        "encap2+3") DPDK_BOND_POLICY="l23";;
        "encap3+4") DPDK_BOND_POLICY="l34";;
    esac

    DPDK_BOND_PCIS=""
    DPDK_BOND_NUMA=""
    ## Bond Members
    for slave in ${DPDK_BOND_SLAVES}; do
        slave_dir="/sys/class/net/${slave}"

        slave_pci=`readlink ${slave_dir}/device`
        slave_pci=${slave_pci##*/}
        slave_numa=`cat ${slave_dir}/device/numa_node`
        slave_mac=`cat ${slave_dir}/address`
        if [ -n "${slave_pci}" ]; then
            DPDK_BOND_PCIS="${DPDK_BOND_PCIS} ${slave_pci}"
        fi
        if [ -z "${DPDK_BOND_NUMA}" ]; then
            # DPDK EAL for bond interface interprets -1 as 255
            if [ "${slave_numa}" -eq -1 ]; then
                DPDK_BOND_NUMA=0
            else
                DPDK_BOND_NUMA="${slave_numa}"
            fi
        fi
    done
    DPDK_BOND_PCIS="${DPDK_BOND_PCIS# }"
}

##
## Wait till bond interface is up and all slaves attached
##
_dpdk_wait_for_bond_ready() {
    #if DPDK_PHY is a vlan, remove the '.'
    bond_name=$(echo ${DPDK_PHY} | cut -d. -f1)
    bond_dir="/sys/class/net/${bond_name}/bonding"
    for iface in $(ifquery --list); do
        ifquery $iface | grep "bond-master" | grep ${bond_name}
        if [ $? -eq 0  ];
        then
            timeout=0
            # Wait upto 60 sec till the interface is enslaved
            while [ $timeout -lt 60 ];
            do
                cat ${bond_dir}/slaves | grep $iface
                if [ $? -ne 0 ];
                then
                    echo "Waiting for interface $iface to be ready"
                    sleep 1
                else
                    echo "Slave interface $iface ready"
                    break
                fi
                timeout=$(expr $timeout + 1)
            done
        fi
    done
}

##
## Bind vRouter/DPDK Interface(s) to DPDK Drivers
## The function is used in pre/post start scripts
##
vrouter_dpdk_if_bind() {
    echo "$(date): Binding interfaces to DPDK drivers..."

    # TODO: This is a temporary workaround for the race between vRouter
    # start and network interfaces set up. There were observed cases when the
    # vRouter had started before the bond0 interface was created, which led to
    # an error as DPDK could not bind to the non-existing interface. In
    # overall, cleanup of the functions in this file should be done to
    # eliminate such workarounds.
    #DPDK_PHY=$(cat $CONFIG | sed -nr 's/^\s*physical_interface\s*=\s*(\S+)\b/\1/p')
    loops=0
    while [ ! -e /sys/class/net/${DPDK_PHY} ]; do
        sleep 2
        #if DPDK_PHY is a vlan on a bond, might need to bring it up explicitly
        # after the slaves are added to the bond (especially if slaves are VFs)
        ifup ${DPDK_PHY}
        loops=$(($loops + 1))
        if [ $loops -ge 60 ]; then
            echo "$(date): Error binding physical interface ${DPDK_PHY}: device not found"
            ${DPDK_BIND} --status
            return 1
        fi
    done

    _dpdk_conf_read
    modprobe "${DPDK_UIO_DRIVER}"
    # multiple kthreads for port monitoring
    if ! _is_ubuntu_xenial; then
        modprobe rte_kni kthread_mode=multiple
    fi

    _dpdk_wait_for_bond_ready
    _dpdk_system_bond_info_collect
    echo " DPDK_BINDING_DRIVER_DATA ${DPDK_BINDING_DRIVER_DATA}"
    echo "DPDK_BOND_PCIS ${DPDK_BOND_PCIS} "
    echo "slave_pci ${slave_pci} "
    echo "DPDK_BOND_MODE ${DPDK_BOND_MODE} "
    echo "DPDK_BOND_SLAVES ${DPDK_BOND_SLAVES} "
 
    mkdir -p ${DPDK_BINDING_DRIVER_DATA}
    for slave_pci in ${DPDK_BOND_PCIS}; do
        if [ ! -e ${DPDK_BINDING_DRIVER_DATA}/${slave_pci} ]; then
            echo "Adding lspci data to ${DPDK_BINDING_DRIVER_DATA}/${slave_pci}"
            `lspci -vmmks ${slave_pci} > ${DPDK_BINDING_DRIVER_DATA}/${slave_pci}`
        fi
    done

    # bind physical device(s) to DPDK driver
    for slave in ${DPDK_BOND_SLAVES}; do
        echo "Binding device ${slave} to UIO driver ${DPDK_UIO_DRIVER}..."
        ${DPDK_BIND} --force --bind="${DPDK_UIO_DRIVER}" ${slave}
    done

    if [ -n "${DPDK_BOND_MODE}" ]; then
        echo "${0##*/}: removing bond interface from Linux..."
        ifdown "${DPDK_PHY}"
        ip link del "${DPDK_PHY}"
    fi

    ${DPDK_BIND} --status

    echo "$(date): Done binding interfaces."
}

##
## Unbind vRouter/DPDK Interface(s) Back to System Drivers
## The function is used in pre/post start scripts
##
vrouter_dpdk_if_unbind() {
    echo "$(date): Unbinding interfaces back to system drivers..."

    _dpdk_conf_read
    echo "$(date): Waiting for vRouter/DPDK to stop..."
    loops=0
    while _is_vrouter_dpdk_running
    do
        sleep 2
        loops=$(($loops + 1))
        if [ $loops -ge 60 ]; then
            echo "$(date): Error stopping ${VROUTER_SERVICE} service: vRouter/DPDK is still running"
            return 1
        fi
    done

    if [ -n "${DPDK_BOND_MODE}" ]; then
        echo "Unbind physical interface ..."
        ${DPDK_BIND} --force --bind=${DPDK_UIO_DRIVER} ${DPDK_PHY_PCI}
    fi

    ## make sure UIO driver is loaded otherwise DPDK_BIND will not work
    modprobe "${DPDK_UIO_DRIVER}"
    for slave_pci_name in ${DPDK_BOND_PCI_NAMES}; do
        eval slave_pci=\${DPDK_BOND_${slave_pci_name}_PCI}
        slave_driver=`grep "Driver:" ${DPDK_BINDING_DRIVER_DATA}/${slave_pci} | cut -f 2 | tr -d ['\n\r']`
        echo "Binding PCI device ${slave_pci} back to ${slave_driver} driver..."
        ${DPDK_BIND} --force --bind=${slave_driver} ${slave_pci}
        rm ${DPDK_BINDING_DRIVER_DATA}/${slave_pci}
    done

    ${DPDK_BIND} --status

    if ! _is_ubuntu_xenial; then
        rmmod rte_kni
    fi
    rmmod "${DPDK_UIO_DRIVER}"

    echo "$(date): Re-initialize networking."
    bond_name=$(echo ${DPDK_PHY} | cut -d. -f1)
    for iface in $(ifquery --list);
    do
        if ifquery $iface | grep -i "$bond_name" | grep -i "bond-master";
        then
            ifdown $iface
         fi
    done
 
    # Make the bond slaves up
    # Bond slaves with automatically make the bond master up
    for iface in $(ifquery --list);
    do
        if ifquery $iface | grep -i "bond-master:";
        then
            ifup $iface
        fi
    done

    # Make other interfaces up (which are still down)
    for iface in $(ifquery --list);
    do
        if ! ifquery --state $iface;
        then
            ifup $iface
         fi
    done

    echo "$(date): Done unbinding interfaces."
}

create_hugepage_config() {
echo 'vm.nr_hugepages=48341' >> /etc/sysctl.conf
echo 'vm.max_map_count = 96682' >> /etc/sysctl.conf
echo 'kernel.core_pattern = /var/crashes/core.%e.%p.%h.%t' >> /etc/sysctl.conf
mkdir -p /hugepages
sudo mount -t hugetlbfs hugetlbfs /hugepages
sysctl -p 
}

vrouter_dpdk_if_unbind
create_hugepage_config
ip address delete ${DPDK_PHY_ADDRESS} dev ${DPDK_PHY}
vrouter_dpdk_if_bind

re='[,-]'
if [[ "${core}" =~ ${re} ]]; then
    taskset_param=' -c'
fi

echo " Starting dpdk binary "
/usr/bin/taskset ${taskset_param} ${DPDK_COREMASK}  /usr/bin/contrail-vrouter-dpdk --no-daemon --socket-mem 1024 &
vrouter_dpdk_start

exec "$@"
