#!/bin/bash

source /network-functions-vrouter-${AGENT_MODE}

#Agents constants
REQUIRED_KERNEL_VROUTER_ENCRYPTION='4.4.0'

function create_vhost_network_functions() {
    local dir=$1
    pushd "$dir"
    /bin/cp -f /ifup-vhost ./
    chmod 644 ./ifup-vhost
    chmod +x ./ifup-vhost
    /bin/cp -f  /network-functions-vrouter /network-functions-vrouter-${AGENT_MODE} ./
    chmod 644 ./network-functions-vrouter ./network-functions-vrouter-${AGENT_MODE}
    popd
}

function copy_agent_tools_to_host() {
    # copy ifup-vhost
    local netscript_dir='/etc/sysconfig/network-scripts'
    if [[ -d "$netscript_dir" ]] ; then
        create_vhost_network_functions "$netscript_dir"
    fi
    # copy vif util
    if [[ ! -f /host/bin/vif ]]; then
        /bin/cp -f /bin/vif /host/bin/vif
        chmod 644 /host/bin/vif
        chmod +x /host/bin/vif
    fi
}

function is_vlan() {
    local dev=${1:-?}
    [ -f "/proc/net/vlan/${dev}" ]
}

function get_vlan_parameters() {
    local dev=${1:-?}
    local vlan_file="/proc/net/vlan/${dev}"
    local vlan_id=''
    local vlan_parent=''
    if [[ -f "${vlan_file}" ]] ; then
        local vlan_data=$(cat "$vlan_file")
        vlan_id=$(echo "$vlan_data" | grep 'VID:' | head -1 | awk '{print($3)}')
        vlan_parent=$(echo "$vlan_data" | grep 'Device:' | head -1 | awk '{print($2)}')
        if [[ -n "$vlan_parent" ]] ; then
            dev=$vlan_parent
        fi
        echo $vlan_id $dev
    fi
}

function is_bonding() {
    local dev=${1:-?}
    [ -d "/sys/class/net/${dev}/bonding" ]
}

function get_bonding_parameters() {
    local dev=${1:-?}
    local bond_dir="/sys/class/net/${dev}/bonding"
    if [[ -d ${bond_dir} ]] ; then
        local mode="$(cat ${bond_dir}/mode | awk '{print $2}')"
        local policy="$(cat ${bond_dir}/xmit_hash_policy | awk '{print $1}')"
        ## Map Linux values to DPDK
        case "${policy}" in
            "layer2") policy="l2";;
            "layer3+4") policy="l34";;
            "layer2+3") policy="l23";;
            # DPDK 2.0 does not support inner packet hashing
            "encap2+3") policy="l23";;
            "encap3+4") policy="l34";;
        esac

        local slaves="$(cat ${bond_dir}/slaves | tr ' ' '\n' | sort | tr '\n' ',')"
        slaves=${slaves%,}

        local pci_addresses=''
        local bond_numa=''
        ## Bond Members
        for slave in $(echo ${slaves} | tr ',' ' ') ; do
            local slave_dir="/sys/class/net/${slave}"
            local slave_pci=$(get_pci_address_for_nic $slave)
            if [[ -n "${slave_pci}" ]] ; then
                pci_addresses+=",${slave_pci}"
            fi
            if [ -z "${bond_numa}" ]; then
                local slave_numa=$(cat ${slave_dir}/device/numa_node)
                # DPDK EAL for bond interface interprets -1 as 255
                if [[ -z "${slave_numa}" || "${slave_numa}" -eq -1 ]] ; then
                    bond_numa=0
                else
                    bond_numa="${slave_numa}"
                fi
            fi
        done
        pci_addresses=${pci_addresses#,}

        echo "$mode $policy $slaves $pci_addresses $bond_numa"
    fi
}

function ifquery_list() {
   grep --no-filename "DEVICE=" /etc/sysconfig/network-scripts/ifcfg-* | cut -c8- | tr -d '"' | sort | uniq
}

function ifquery_dev() {
    local dev=${1:-?}
    local if_file="/etc/sysconfig/network-scripts/ifcfg-$dev"
    if [ -e "$if_file" ] ; then
        if grep -q -e "^MASTER" -e "^SLAVE" "$if_file" ; then
            sed 's/\<MASTER=/bond-master: /g' "$if_file"
        else
            cat "$if_file"
        fi
    fi
}

function wait_bonding_slaves() {
    local dev=${1:-?}
    local bond_dir="/sys/class/net/${dev}/bonding"
    local ret=0
    for iface in $(ifquery_list) ; do
        if ifquery_dev $iface | grep "bond-master" | grep -q ${dev} ; then
            # Wait upto 60 sec till the interface is enslaved
            local i=0
            for i in {1..60} ; do
                if grep -q $iface "${bond_dir}/slaves" ; then
                    echo "INFO: Slave interface $iface ready"
                    i=0
                    break
                fi
                echo "Waiting for interface $iface to be ready... ${i}/60"
                sleep 1
            done
            [ "$i" != '60' ] || { ret=1 && echo "ERROR: failed to wait $iface to be enslaved" ; }
        fi
    done
    return $ret
}

function get_pci_address_for_nic() {
    local nic=${1:-?}
    if is_vlan $nic ; then
        local vlan_id=''
        local vlan_parent=''
        IFS=' ' read -r vlan_id vlan_parent <<< $(get_vlan_parameters $nic)
        nic=$vlan_parent
    fi
    if ! is_bonding $nic ; then
        ethtool -i ${nic} | grep bus-info | awk '{print $2}' | tr -d ' '
    else
        echo '0000:00:00.0'
    fi
}

function get_physical_nic_and_mac()
{
  local nic='vhost0'
  local mac=$(get_iface_mac $nic)
  if [[ -n "$mac" ]] ; then
    # it means vhost0 iface is already up and running,
    # so try to find physical nic by MAC (which should be
    # the same as in vhost0)
    nic=`vif --list | grep "Type:Physical HWaddr:${mac}" -B1 | head -1 | awk '{print($3)}'`
    if [[ -n "$nic" && ! "$nic" =~ ^[0-9] ]] ; then
        # NIC case, for DPDK case nic is number, so use mac from vhost0 there
        local _mac=$(get_iface_mac $nic)
        if [[ -n "$_mac" ]] ; then
            mac=$_mac
        else
            echo "ERROR: unsupported agent mode" >&2
            return 1
        fi
    else
        # DPDK case, nic name is not exist, so set it to default
        nic=$(get_vrouter_physical_iface)
    fi
  else
    # there is no vhost0 device, so then get vrouter physical interface
    nic=$(get_vrouter_physical_iface)
    mac=$(get_iface_mac $nic)
  fi
  # Ensure that nic & mac are not empty
  if [[ "$nic" == '' || "$mac" == '' ]] ; then
      echo "ERROR: either phys nic or mac is empty: phys_int='$nic' phys_int_mac='$mac'" >&2
      return 1
  fi
  echo $nic $mac
}

# Find the overlay interface on a ContrailVM
# ContrailVM is spawned with nic ens160, which is the primary interface
# Secondary nics (like ens192, ens224) are added during provisioning
# The overlay interface will have name ens* and not have inet* configured
# This function uses this logic to find the overlay interface and
# return as vmware_physical_interface.
function get_vmware_physical_iface()
{
  local iface_list=`ip -o link show | awk -F': ' '{print $2}'`
  iface_list=`echo "$iface_list" | grep -v 'vhost0\|docker0\|pkt[0-9]\+\|ens160\|lo'`
  for iface in $iface_list; do
      ip addr show dev $iface | grep 'inet*' > /dev/null 2>&1
      if [[ $? == 0 ]]; then
          continue;
      else
          vmware_int=$iface
      fi
  done
  if [[ "$vmware_int" == '' ]]; then
      echo "ERROR: vmware_physical_interface not configured"
      exit -1
  fi
  echo $vmware_int
}

function enable_hugepages_to_coredump() {
    local name=$1
    local pid=$(pidof $name)
    echo "INFO: enable hugepages to coredump for $name with pid=$pid"
    local coredump_filter="/proc/$pid/coredump_filter"
    local cdump_filter=0x73
    if [[ -f "$coredump_filter" ]] ; then
        cdump_filter=`cat "$coredump_filter"`
        cdump_filter=$((0x40 | 0x$cdump_filter))
    fi
    echo $cdump_filter > "$coredump_filter"
}

function probe_nic () {
    local nic=$1
    local probes=${2:-1}
    while (( probes > 0 )) ; do
        echo "INFO: Probe ${nic}... tries left $probes"
        local mac=$(get_iface_mac $nic)
        if [[ -n "$mac" ]]; then
            return 0
        fi
        (( probes -= 1))
        sleep 1
    done
    return 1
}

function wait_device_for_driver () {
    local driver=$1
    local pci_address=$2
    local i=0
    for i in {1..60} ; do
        echo "INFO: Waiting device $pci_address for driver ${driver} ... $i"
        if [[ -L /sys/bus/pci/drivers/${driver}/${pci_address} ]] ; then
            return 0
        fi
        sleep 2
    done
    return 1
}

# TODO: move to agent specific file
function is_dpdk_running() {
    netstat -xl | grep -q  dpdk_netlink
}

function wait_dpdk_start() {
    local i=0
    for i in {1..60} ; do
        echo "INFO: wait DPDK agent to run... $i"
        if is_dpdk_running ; then
            return 0
        fi
        sleep 5
    done
    return 1
}

function create_vhost0_dpdk() {
    local phys_int=$1
    local phys_int_mac=$2
    echo "INFO: Creating ${phys_int} interface with mac $phys_int_mac via vif utility..."
    if ! vif --add 0 --mac ${phys_int_mac} --vrf 0 --vhost-phys --type physical --pmd --id 0 ; then
        echo "ERROR: Failed to adding ${phys_int} interface"
        return 1
    fi
    echo "INFO: Adding vhost0 interface with vif utility..."
    if ! vif --add vhost0 --mac ${phys_int_mac} --vrf 0 --type vhost --xconnect 0 --pmd --id 1 ; then
        echo "ERROR: Failed to add vhost0 interface"
        return 1
    fi
    if ! ip link set dev vhost0 up ; then
        echo "ERROR: Failed to up vhost0 interface"
        return 1
    fi
    if ! ip link set dev vhost0 address $phys_int_mac ; then
        echo "ERROR: Failed to set vhost0 address $phys_int_mac"
        return 1
    fi
}

function save_pci_info() {
    local pci=$1
    local binding_data_dir='/var/run/vrouter'
    local binding_data_file="${binding_data_dir}/${pci}"
    if [[ ! -e "$binding_data_file" ]] ; then
        local pci_data=`lspci -vmmks ${pci}`
        echo "INFO: Add lspci data to ${binding_data_file}"
        echo "$pci_data"
        echo "$pci_data" > ${binding_data_file}
    else
        echo "INFO: lspci data for $pci already exists"
    fi
}

function bind_devs_to_driver() {
    local driver=$1
    shift 1
    local pci=( $@ )

    if [ -z "${driver}" ] ; then
        return 0
    fi

    # bind physical device(s) to DPDK driver
    local ret=0
    local n=''
    for n in ${pci[@]} ; do
        echo "INFO: Binding device $n to driver $driver ..."
        save_pci_info $n
        if ! /opt/contrail/bin/dpdk_nic_bind.py --force --bind="$driver" $n ; then
            echo "ERROR: Failed to bind $n to driver $driver"
            return 1
        fi
        if ! wait_device_for_driver $driver $n ; then
            echo "ERROR: Failed to wait device $n to appears for driver $driver"
            return 1
        fi
    done
}

function get_addrs_for_nic() {
    local nic=$1
    ip addr show dev $nic | grep "inet" | grep -oP "[0-9a-f\:\.]*/[0-9]* brd [0-9\.]*|[0-9a-f\:\.]*/[0-9]*"
}

function prepare_phys_int_dpdk
{
    if probe_nic vhost0 ; then
        echo "INFO: vhost device is already exist"
        return 0
    fi
    declare phys_int phys_int_mac pci
    local count=0
    while (true) ; do
        echo "INFO: detecting phys interface parameters... ${count}/10"
        IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
        pci=$(get_pci_address_for_nic $phys_int)
        if [[ -n "$phys_int" && -n "$phys_int_mac" && -n "$pci" ]] ; then
            break
        fi
        if (( count == 10 )) ; then
            echo "ERROR: failed to detect one of mandatory phys interface parameters" >&2
            echo "ERROR: phys_int=$phys_int phys_int_mac=$phys_int_mac, pci=$pci" >&2
            return 1
        fi
        sleep 6
    done
    local nic=$phys_int
    local addrs=$(get_addrs_for_nic $phys_int)
    local _default_gw_metric=`get_default_gateway_for_nic_metric $phys_int`
    local gateway=${VROUTER_GATEWAY:-"$_default_gw_metric"}
    echo "INFO: phys_int=$phys_int phys_int_mac=$phys_int_mac, pci=$pci, addrs=[$addrs], gateway=$gateway"


    # save data for next usage in network init container
    # TODO: check that data valid for the case if container is re-run again by some reason
    local binding_data_dir='/var/run/vrouter'
    mkdir -p ${binding_data_dir}

    echo "$nic" > $binding_data_dir/nic
    echo "$phys_int_mac" > $binding_data_dir/${nic}_mac
    echo "$pci" > $binding_data_dir/${nic}_pci
    echo "$addrs" > $binding_data_dir/${nic}_ip_addresses
    echo "$gateway" > $binding_data_dir/${nic}_gateway

    if is_vlan $phys_int ; then
        local vlan_id=''
        local vlan_parent=''
        IFS=' ' read -r vlan_id vlan_parent <<< $(get_vlan_parameters $phys_int)
        echo "$vlan_id $vlan_parent" > $binding_data_dir/${nic}_vlan
        # change device for detecting othe options like PCIs, etc
        phys_int=$vlan_parent
        echo "INFO: vlan: echo vlan_id=$vlan_id vlan_parent=$vlan_parent"
    fi

    local pci_addresses=$pci
    if is_bonding $phys_int ; then
        wait_bonding_slaves $phys_int
        local mode=''
        local policy=''
        local slaves=''
        local bond_numa=''
        IFS=' ' read -r mode policy slaves pci_addresses bond_numa <<< $(get_bonding_parameters $phys_int)
        echo "$mode $policy $slaves $pci_addresses $bond_numa" > $binding_data_dir/${nic}_bond
        echo "INFO: bonding: $mode $policy $slaves $pci_addresses $bond_numa"
        echo "INFO: bonding: removing bond interface from Linux..."
        ifdown $phys_int
        ip link del $phys_int
    fi

    bind_devs_to_driver "$DPDK_UIO_DRIVER" "${pci_addresses//,/ }"
}


function ensure_hugepages() {
    local hp_dir=${1:?}
    local hp_dir_mount_type="hugetlbfs $hp_dir hugetlbfs"
    if ! grep -qs "$hp_dir_mount_type" /proc/mounts ; then
        echo "ERROR: Hupepages dir($hp_dir) does not have hugetlbfs mount type"
        exit -1
    fi
}

function init_vhost0() {
    # Probe vhost0
    local vrouter_cidr="$(get_cidr_for_nic vhost0)"
    if [[ "$vrouter_cidr" != '' ]] ; then
        echo "INFO: vhost0 is already up"
        return 0
    fi
    local phys_int=''
    local phys_int_mac=''
    local addrs=''
    local gateway=''
    local bind_type=''
    if ! is_dpdk ; then
        # NIC case
        bind_type='kernel'
        IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
        addrs=$(get_addrs_for_nic $phys_int)
        local default_gw_metric=`get_default_gateway_for_nic_metric $phys_int`
        gateway=${VROUTER_GATEWAY:-"$default_gw_metric"}
        echo "INFO: creating vhost0 for nic mode: nic: $phys_int, mac=$phys_int_mac"
        if ! create_vhost0 $phys_int $phys_int_mac ; then
            return 1
        fi
    else
        # DPDK case
        bind_type='dpdk'
        # TODO: rework someow config pathching..
        if ! wait_dpdk_start ; then
            return 1
        fi
        local binding_data_dir='/var/run/vrouter'
        phys_int=`cat $binding_data_dir/nic`
        phys_int_mac=`cat $binding_data_dir/${phys_int}_mac`
        local pci_address=`cat $binding_data_dir/${phys_int}_pci`
        # TODO: This part of config is needed for vif tool to work,
        # later full config will be written.
        # Maybe rework someow config pathching..
        cat << EOM > /etc/contrail/contrail-vrouter-agent.conf
[DEFAULT]
platform=${AGENT_MODE}
physical_interface_mac = $phys_int_mac
physical_interface_address = $pci_address
physical_uio_driver = ${DPDK_UIO_DRIVER}
EOM
        addrs=`cat $binding_data_dir/${phys_int}_ip_addresses`
        default_gateway="$(cat $binding_data_dir/${phys_int}_gateway)"
        gateway=${VROUTER_GATEWAY:-$default_gateway}
        echo "INFO: creating vhost0 for dpdk mode: nic: $phys_int, mac=$phys_int_mac"
        if ! create_vhost0_dpdk $phys_int $phys_int_mac ; then
            return 1
        fi
    fi

    local ret=0
    if [[ -e /etc/sysconfig/network-scripts/ifcfg-${phys_int} ]]; then
        echo "INFO: creating ifcfg-vhost0 and initialize it via ifup"
        if ! is_dpdk ; then
            ifdown ${phys_int}
            local dhcpcl_id=$(ps -efa | grep dhclient | grep -v grep | grep ${phys_int} | awk '{print $2}')
            if [ -n "$dhcpcl_id" ]; then
                kill -9 $dhcpcl_id
            fi
        fi
        pushd /etc/sysconfig/network-scripts/

        if [[ -f route-${phys_int} ]]; then
          /bin/cp -f route-${phys_int} route-vhost0
          mv route-${phys_int} contrail.org.route-${phys_int}
        fi
        if [ ! -f "contrail.org.ifcfg-${phys_int}" ] ; then
            /bin/cp -f ifcfg-${phys_int} contrail.org.ifcfg-${phys_int}
            sed -r "/(DEVICE|TYPE|ONBOOT|MACADDR|HWADDR|BONDING|SLAVE|VLAN|MTU)/! s/^[^#].*/#commented_by_contrail& /" ifcfg-${phys_int} > ifcfg-${phys_int}.tmp
            echo 'NM_CONTROLLED=no' >> ifcfg-${phys_int}.tmp
            echo 'BOOTPROTO=none' >> ifcfg-${phys_int}.tmp
            mv ifcfg-${phys_int}.tmp ifcfg-${phys_int}
        fi
        if [[ ! -f ifcfg-vhost0 ]] ; then
            sed "s/${phys_int}/vhost0/g" contrail.org.ifcfg-${phys_int} > ifcfg-vhost0.tmp
            sed -ri '/(TYPE|NM_CONTROLLED|MACADDR|HWADDR|BONDING|SLAVE|VLAN)/d' ifcfg-vhost0.tmp
            echo "TYPE=${bind_type}" >> ifcfg-vhost0.tmp
            echo 'NM_CONTROLLED=no' >> ifcfg-vhost0.tmp
            echo "BIND_INT=${phys_int}" >> ifcfg-vhost0.tmp
            echo "BIND_INT_MAC=${phys_int_mac}" >> ifcfg-vhost0.tmp
            mv ifcfg-vhost0.tmp ifcfg-vhost0
        fi
        popd
        if ! is_dpdk ; then
            ifup ${phys_int} || { echo "ERROR: failed to ifup $phys_int." && ret=1; }
        fi
        ifdown vhost0
        ifup vhost0 || { echo "ERROR: failed to ifup vhost0." && ret=1; }
        while IFS= read -r line ; do
            ip route del $line || { echo "ERROR: route $line was not removed for iface ${phys_int}." && ret=1; }
        done < <(ip route sh | grep ${phys_int})
    else
        echo "INFO: there is no ifcfg-$phys_int, so initialize vhost0 manually"
        # TODO: switch off dhcp on phys_int
        echo "INFO: Changing physical interface to vhost in ip table"
        echo "$addrs" | while IFS= read -r line ; do
            if ! is_dpdk ; then
                addr_to_del=`echo $line | cut -d ' ' -f 1`
                ip address delete $addr_to_del dev $phys_int || { echo "ERROR: failed to del $addr_to_del from ${phys_int}." && ret=1; }
            fi
            local addr_to_add=`echo $line | sed 's/brd/broadcast/'`
            ip address add $addr_to_add dev vhost0 || { echo "ERROR: failed to add address $addr_to_del to vhost0." && ret=1; }
        done
        if [[ -n "$gateway" ]]; then
            echo "INFO: set default gateway"
            ip route add default via $gateway || { echo "ERROR: failed to add default gateway $gateway" && ret=1; }
        fi
    fi
    return $ret
}

function init_sriov() {
    # check whether sriov enabled
    if ! is_sriov ; then
        return
    fi

    echo "INFO: SRIOV Enabled"
    local  sriov_numvfs="/sys/class/net/${SRIOV_PHYSICAL_INTERFACE}/device/sriov_numvfs"
    if [[ -f "$sriov_numvfs" ]] ; then
        echo "$SRIOV_VF" > $sriov_numvfs
    fi
}

# Generate ip address add command
function gen_ip_addr_add_cmd() {
    local from_nic=$1
    local to_nic=$2
    local addrs=`get_addrs_for_nic $from_nic`
    declare line cmd

    while IFS= read -r line ; do
        local addr_to_add=$(echo $line | sed 's/brd/broadcast/')
        if [[ -n $cmd ]]; then
            cmd+=" && "
        fi
        cmd+="ip address add $addr_to_add dev $to_nic"
    done <<< "$addrs"
    echo $cmd
}

function cleanup_lbaas_netns_config() {
    rm -rf /var/lib/contrail/loadbalancer/*
    rm -rf /var/run/netns/
}

function cleanup_contrail_cni_config() {
    rm -f /opt/cni/bin/contrail-k8s-cni
    rm -f /etc/cni/net.d/10-contrail.conf
}

# remove vhost0 interface for kernel based node
function remove_vhost0_kernel() {
    local phys_int=$1
    local vhost="vhost0"
    local add_ipaddr_cmd=$(gen_ip_addr_add_cmd $vhost $phys_int)
    local gateway=$(get_default_gateway_for_nic_metric $vhost)

    if [[ $(lsmod | grep vrouter | awk '{print $1}') == 'vrouter' ]]; then
        # Wait for vrouter module to be free for use
        while [[ $(lsmod | grep vrouter | awk '{print $3}') != '0' ]]; do
            sleep 1s;
        done
        echo "INFO: Unloading kernel module and bringing up $phys_int"
        if [[ -f "/etc/sysconfig/network-scripts/ifcfg-${phys_int}" ]]; then
            ip link del vhost0 && rmmod vrouter && { ifdown $phys_int 2>/dev/null; ifup $phys_int ; }
        else
            ip link del vhost0 && rmmod vrouter && eval "$add_ipaddr_cmd"
            if [[ ! -z "${gateway// }" ]]; then
                echo "INFO: set default gateway"
                ip route add default via $gateway || echo "ERROR: failed to add default gateway $gateway"
            fi
        fi
    fi
}


# generic remove vhost functionality
function remove_vhost0() {
    declare phys_int phys_int_mac
    if ! is_dpdk ; then
        IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
        echo "INFO: removing vhost0"
        remove_vhost0_kernel ${phys_int}
    fi
}

# Modify/Deletes files created by agent container
function cleanup_vrouter_agent_files() {
    local phys_int=$1

    if [[ -e /etc/sysconfig/network-scripts/ifcfg-vhost0 ]]; then
        pushd /etc/sysconfig/network-scripts/

        if [ -f "contrail.org.ifcfg-${phys_int}" ] ; then
            # override ifcfg-${phys_int} file created by vrouter-agent container
            /bin/cp -f contrail.org.ifcfg-${phys_int} ifcfg-${phys_int}
            rm -f contrail.org.ifcfg-${phys_int}
            rm -f ifcfg-vhost0
        fi

        if [[ -f "contrail.org.route-${phys_int}" ]]; then
            # override route-${phys_int} file created by vrouter-agent container
            /bin/cp -f contrail.org.route-${phys_int} route-${phys_int}
            rm -f contrail.org.route-${phys_int}
            rm -f route-vhost0
        fi
        popd
    fi

    # remove config file
    rm -rf /etc/contrail/contrail-vrouter-agent.conf
}

# terminate vrouter agent process
function term_vrouter_agent() {
    local vrouter_agent_process=$1
    local phys_int=$2
    declare process_exists
    process_exists=$(kill -0 $vrouter_agent_process &>/dev/null)
    if $process_exists; then
        echo "INFO: terminating vrouter agent process"
        kill -KILL "$vrouter_agent_process" &>/dev/null
        wait $vrouter_agent_process
    fi
    cleanup_vrouter_agent_files $phys_int
}

# send quit signal to root process
function quit_root_process() {
    kill -QUIT 1
}

# send SIGHUP signal to child process
function send_sighup_child_process(){
    local child_process=$1
    kill -HUP "$child_process"
}

# In release 5.0, vrouter to vrouter encryption
# works only on kernels 4.4 and above
function is_encryption_supported() {
    local encryption_supported=1
    kernel_version=`uname -r | cut -d "-" -f 1`
    if (( $(echo "$kernel_version $REQUIRED_KERNEL_VROUTER_ENCRYPTION" | awk '{print ($1 >= $2)}') )); then
       encryption_supported=0
    fi
    return $encryption_supported
}

# create the ipvlan interface for
# vrouter to vrouter datapath encryption
function init_crypt0() {
    # Check if the kernel is 4.4 or greater
    local ret=0
    local crypt_intf=$1
    crypt0=`ip link show $crypt_intf | grep -wo $crypt_intf`
    if [ "$crypt0" == "$crypt_intf" ]; then
       echo "INFO: $crypt_intf already exists"
       return $ret
    fi
    local ipvlan=`lsmod | grep -wo ipvlan`
    local aes=`grep -o aes /proc/cpuinfo`
    local mtu=`cat /sys/class/net/vhost0/mtu`
    if [ "$ipvlan" != "ipvlan" ]; then
        modprobe ipvlan || { echo "ERROR: Failed to modprobe ipvlan kernel module" && return 1; }
    fi
    if [ "$aes" == "aes" ]; then
       local aesni=`lsmod | grep -wo aesni_intel`
       if [ "$aesni" != "aesni_intel" ]; then
          modprobe aesni_intel || { echo "ERROR: Failed to modprobe aesni_intel kernel module. Proceeding without aesni module." && ret=0; }
       fi
    fi
    ip link add $crypt_intf link vhost0 type ipvlan || { echo "ERROR: Failed to initialize ipvlan interface $crypt_intf" && return 1; }
    ip link set dev $crypt_intf mtu $mtu up
    echo "Successfully added ipvlan interface $crypt_intf"
    return $ret
}

function create_iptables_vrouter_encryption() {
    local ret=0
    local key=$1
    local mplsoudp_port=`iptables -L -nvx -t mangle | grep -wo 6635`
    local vxlanoudp_port=`iptables -L -nvx -t mangle | grep -wo 4789`
    local gre=`iptables -L -nvx -t mangle | grep -wo 47`
    # create iptables rule for marking the packets such that IPSec kernel can process such packets
    # UDP posrt 6635 - MPLSoUDP, 4789 - VXLAN UDP DST port
    if [[ $mplsoudp_port != 6635 ]]; then
       iptables -I OUTPUT -t mangle -p udp --dport 6635 -j MARK --set-mark $key || { echo "ERROR: Failed to add iptables rule for MPLS0UDP encryption" && ret=1; }
    fi
    if [[ $vxlanoudp_port != 4789 ]]; then
       iptables -I OUTPUT -t mangle -p udp --dport 4789 -j MARK --set-mark $key || { echo "ERROR: Failed to add iptables rule for VXLANoUDP encryption" && ret=1; }
    fi
    if [[ $gre != 47 ]]; then
       iptables -I OUTPUT -t mangle -p gre -j MARK --set-mark $key || { echo "ERROR: Failed to add iptables rule for GRE encryption" && ret=1; }
    fi
    return $ret
}

# create decrypt interface for vrouter
# to vrouter encryption
function init_decrypt0() {
    local ret=0
    local decrypt_intf=$1
    local key=$2
    decrypt0=`ip link show $decrypt_intf | grep -wo $decrypt_intf`
    if [ "$decrypt0" == "$decrypt_intf" ]; then
         echo "INFO: $decrypt_intf already exists"
         create_iptables_vrouter_encryption $key
         return $ret
    fi
    local mtu=`cat /sys/class/net/vhost0/mtu`
    local l_ip=$(get_listen_ip_for_nic vhost0)
    ip tunnel add $decrypt_intf local $l_ip mode vti key $key || { echo "ERROR: Failed to initialize tunnel interface $decrypt_intf" && return 1; }
    ip link set dev $decrypt_intf mtu $mtu up
    ip link set dev ip_vti0 mtu $mtu up
    create_iptables_vrouter_encryption $key
    echo "Successfully added tunnel interface $decrypt_intf and the required iptables rules"
    return $ret
}

# add the decrypt interface to vrouter
# this will be required till vrouter agent
# has the native support for decrrpt interface
function add_vrouter_decrypt_intf() {
    local ret=0
    local decrypt_intf=$1
    local mac=$(get_iface_mac vhost0)
    decrypt_intf_up=`ip link show $decrypt_intf | grep -wo UP`
    if [ "$decrypt_intf_up" == "UP" ]; then
       # wait for vif to initialize
       sleep 2
       local vif_decrypt_intf=`vif --list | grep -wo $decrypt_intf`
       if [ "$vif_decrypt_intf" != "$decrypt_intf" ]; then
          vif --add $decrypt_intf --mac $mac --vrf 0 --vhost-phys --type physical || { echo "ERROR: Failed to add decrypt interface $decrypt_intf to vrouter" && return 1; }
          echo "Successfully added tunnel interface $decrypt_intf to vrouter"
       fi
    fi
    return $ret
}
