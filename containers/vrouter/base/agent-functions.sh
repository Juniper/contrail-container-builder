#!/bin/bash

source /network-functions-vrouter-${AGENT_MODE}

#Agents constants
REQUIRED_KERNEL_VROUTER_ENCRYPTION='4.4.0'

function get_default_gateway_for_nic() {
  local nic=$1
  ip route show dev $nic | grep default | head -n 1 | awk '{print $3}'
}

function get_default_vrouter_gateway() {
    local node_ip=$(resolve_1st_control_node_ip)
    local gw=$(get_gateway_nic_for_ip $node_ip)
    get_default_gateway_for_nic $gw
}

function create_vhost_network_functions() {
    local dir=$1
    pushd "$dir"
    /bin/cp -f /ifup-vhost /ifdown-vhost ./
    chmod 744 ./ifup-vhost ./ifdown-vhost
    /bin/cp -f  /network-functions-vrouter /network-functions-vrouter-${AGENT_MODE} ./
    chmod 644 ./network-functions-vrouter ./network-functions-vrouter-${AGENT_MODE}
    if [ -f /network-functions-vrouter-${AGENT_MODE}-env ] ; then
        local _ct=$(cat /network-functions-vrouter-${AGENT_MODE}-env)
        eval "echo \"$_ct\"" > ./network-functions-vrouter-${AGENT_MODE}-env
        chmod 644 ./network-functions-vrouter-${AGENT_MODE}-env
    fi
    popd
}

function copy_agent_tools_to_host() {
    # copy ifup-vhost
    local netscript_dir='/etc/sysconfig/network-scripts'
    if [[ -d "$netscript_dir" ]] ; then
        create_vhost_network_functions "$netscript_dir"
    fi
    # copy vif util
    /bin/cp -f /bin/vif /host/bin/vif
    chmod 644 /host/bin/vif
    chmod +x /host/bin/vif
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
        vlan_id=`echo "$vlan_data" | grep 'VID:' | head -1 | awk '{print($3)}'`
        vlan_parent=`echo "$vlan_data" | grep 'Device:' | head -1 | awk '{print($2)}'`
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
        local lacp_rate="$(cat ${bond_dir}/lacp_rate | awk '{print $2}')"
        policy=$(convert_bond_policy $policy)
        mode=$(convert_bond_mode $mode)

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
                bond_numa=$(get_bond_numa $slave_pci)
            fi
        done
        pci_addresses=${pci_addresses#,}

        echo "$mode $policy $slaves $pci_addresses $bond_numa $lacp_rate"
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

function find_phys_nic_by_mac() {
    local mac=$1
    local nics=$(find /sys/class/net -mindepth 1 -maxdepth 1 ! -name vhost0 ! -name lo -printf "%P " -execdir cat {}/address \; | grep "$mac" | cut -s -d ' ' -f 1)
    [ -z "$nics" ] && return
    # nics may consists of several nics in case of bond/vlans
    # 1 - check vlans
    local n=''
    for n in $nics ; do
        if is_vlan $n ; then
            echo $n
            return
        fi
    done
    #2 - check bonds
    local n=''
    for n in $nics ; do
        if is_bonding $n ; then
            echo $n
            return
        fi
    done
    # check if only one nic is found
    # > 1 means that nic cannot be identified automatically
    local count=$(echo "$nics" | wc -l)
    if [[ $count != 1 ]] ; then
        return 1
    fi
    # just
    echo $nics
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
    # WA: CEM-9368: there case when vif doesnt return phys device => try to read from ip link
    if [[ -z "$nic" ]] ; then
        nic=$(find_phys_nic_by_mac $mac)
    fi
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
  # Ensure nic is not wrongly detected as vhost0
  if [[ "$nic" == 'vhost0' ]] ; then
      echo "ERROR: Failed to lookup for phys_int for already running vhost0 with mac='$mac'" >&2
      return 1
  fi

  echo $nic $mac
}

# Find the overlay interface on a ContrailVM
# ContrailVM is spawned with nic ens160, which is the primary/mgmt interface
# Secondary nics (like ens192, ens224) are added during provisioning
# The overlay interface will have name ens*, be of type vmxnet3
# and not  have inet address configured
# This function uses this logic to find the overlay interface and
# return as vmware_physical_interface.
function get_vmware_physical_iface() {
    local vmware_int=''
    local iface=''
    local iface_list=`ip -o link show | awk -F': ' '{print $2}'`
    iface_list=`echo "$iface_list" | grep ens`
    for iface in $iface_list; do
        local intf_type=`ethtool -i $iface | grep driver | cut -f 2 -d ' '`
        if [[ $intf_type != "vmxnet3" ]]; then
             continue;
        else
             ip addr show dev $iface | grep 'inet ' > /dev/null 2>&1
             if [[ $? == 0 ]]; then
                  continue;
             else
                  vmware_int=$iface
             fi
        fi
    done
    if [[ "$vmware_int" == '' ]]; then
        echo "ERROR: vmware_physical_interface not configured"
        exit -1
    fi
    echo $vmware_int
}

function disable_chksum_offload() {
    local intf=$1
    local intf_type=`ethtool -i $intf | grep driver | cut -f 2 -d ' '`
    if [[ $intf_type == "vmxnet3" ]]; then
        ethtool --offload $intf rx off
        ethtool --offload $intf tx off
    fi
}

function disable_lro_offload() {
    local intf=$1
    ethtool --offload $intf lro off
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

function read_phys_int_mac_pci_dpdk() {
    if [[ -z "$BIND_INT" ]] ; then
        declare phys_int phys_int_mac pci
        IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
        pci=$(get_pci_address_for_nic $phys_int)
        echo $phys_int $phys_int_mac $pci
        return
    fi
    # in case of running from ifup in tripleo there is no way to read params from system,
    # all of them are to be available from ifcfg-vhost0 (that are passed via env to container)
    ifcfg_read_phys_int_mac_pci_dpdk
}

function read_and_save_dpdk_params() {
    local binding_data_dir='/var/run/vrouter'
    if [ -f $binding_data_dir/nic ] ; then
        echo "WARNING: binding information is already saved"
        return
    fi

    declare phys_int phys_int_mac pci
    IFS=' ' read -r phys_int phys_int_mac pci <<< $(read_phys_int_mac_pci_dpdk)

    local addrs
    local mtu
    local routes
    if [ -z "$BIND_INT" ] ; then
        # read additional data from phys nic in non OSP case only
        addrs=$(get_addrs_for_nic $phys_int)
        mtu=$(get_iface_mtu $phys_int)
        routes=$(get_dev_routes $phys_int)
    fi

    echo "INFO: phys_int=$phys_int phys_int_mac=$phys_int_mac, pci=$pci, addrs=[$addrs], routes=[$routes]"
    local nic=$phys_int

    # save data for next usage in network init container
    mkdir -p ${binding_data_dir}

    echo "$phys_int_mac" > $binding_data_dir/${nic}_mac
    echo "$pci" > $binding_data_dir/${nic}_pci
    echo "$addrs" > $binding_data_dir/${nic}_ip_addresses
    echo "$mtu" > $binding_data_dir/${nic}_mtu
    echo "$routes" > $binding_data_dir/${nic}_routes

    declare vlan_id vlan_parent
    if [ -n "$BIND_INT" ] ; then
        # In case of OSP: VLAN_ID is set to if vlan is used.
        # so, no needs to resolve.
        vlan_id=$VLAN_ID
        vlan_parent=$phys_int
    else
        # read from system
        if is_vlan $phys_int ; then
            IFS=' ' read -r vlan_id vlan_parent <<< $(get_vlan_parameters $phys_int)
            phys_int=$vlan_parent
        fi
    fi
    if [ -n "$vlan_id" ] ; then
        echo "$vlan_id $vlan_parent" > $binding_data_dir/${nic}_vlan
        # change device for detecting othe options like PCIs, etc
        echo "INFO: vlan: echo vlan_id=$vlan_id vlan_parent=$vlan_parent"
    fi

    declare mode policy slaves pci bond_numa lacp_rate
    if [ -n "$BIND_INT" ] ; then
        # In case of OSP: params come from ifcfg.
        if [ -n "$BOND_MODE" ] ; then
            mode=$BOND_MODE
            policy=$(convert_bond_policy $BOND_POLICY)
            mode=$(convert_bond_mode ${mode})
            slaves=''
            declare _slave
            for _slave in ${BIND_INT//,/ } ; do
                [ -n "$slaves" ] && slaves+=','
                slaves+="$(get_ifname_by_pci $_slave)"
            done
            pci=$BIND_INT
            _slave=$(echo ${slaves//,/ } | cut -d ',' -f 1)
            bond_numa=$(get_bond_numa $_slave)
	        echo "0000:00:00.0"  > $binding_data_dir/${nic}_pci
            lacp_rate=${LACP_RATE:-0}
        fi
    else
        # read from system
        if is_bonding $phys_int ; then
            wait_bonding_slaves $phys_int
	        echo "0000:00:00.0"  > $binding_data_dir/${nic}_pci
            IFS=' ' read -r mode policy slaves pci bond_numa lacp_rate <<< $(get_bonding_parameters $phys_int)
        fi
    fi
    if [ -n "$mode" ] ; then
        echo "$mode $policy $slaves $pci $bond_numa $lacp_rate" > $binding_data_dir/${nic}_bond
        echo "INFO: bonding: $mode $policy $slaves $pci $bond_numa $lacp_rate"
    fi

    # Save this file latest because it is used
    # as an sign that params where saved succesfully
    echo "$nic" > $binding_data_dir/nic
}

function ensure_hugepages() {
    local hp_dir=${1:?}
    local hp_dir_mount_type="hugetlbfs $hp_dir hugetlbfs"
    if ! grep -qs "$hp_dir_mount_type" /proc/mounts ; then
        echo "ERROR: Hupepages dir($hp_dir) does not have hugetlbfs mount type"
        exit -1
    fi
}

function check_vrouter_agent_settings() {
    # check that all control nodes accessible via the same interface and this interface is vhost0
    local nodes=(`echo $CONTROL_NODES | tr ',' ' '`)
    if [[ ${#nodes} == 0 ]]; then
        echo "ERROR: CONTROL_NODES list is empty or incorrect ($CONTROL_NODES)."
        echo "ERROR: Please define CONTROL_NODES list."
        return 1
    fi

    local iface=`get_gateway_nic_for_ip ${nodes[0]}`
    if [[ "$iface" != 'vhost0' ]]; then
        echo "WARNING: First control node isn't accessible via vhost0 (or via interface that vhost0 is based on). It's valid for gateway mode and invalid for normal mode."
    fi
    if (( ${#nodes} > 1 )); then
        for node in ${nodes[@]} ; do
            local cur_iface=`get_gateway_nic_for_ip $node`
            if [[ "$iface" != "$cur_iface" ]]; then
                echo "ERROR: Control node $node is accessible via different interface ($cur_iface) than first control node ${nodes[0]} ($iface)."
                echo "ERROR: Please define CONTROL_NODES list correctly."
                return 1
            fi
        done
    fi

    return 0
}

function ensure_host_resolv_conf() {
    local path='/etc/resolv.conf'
    local host_path="/host${path}"
    if [[ -e $path && -e $host_path  ]] && ! diff -U 3 $host_path $path > /dev/null 2>&1 ; then
        local container_content=$(cat $path)
        echo -e "INFO: $path:\n${container_content}"
        echo -e "INFO: $host_path:\n$(cat $host_path)"
        if [ -n "$container_content" ] ; then
            echo "INFO: sync $path to $host_path"
            cp -f $path $host_path
        fi
    fi
}

function init_vhost0() {
    # Probe vhost0
    local vrouter_cidr="$(get_cidr_for_nic vhost0)"
    if [[ "$vrouter_cidr" != '' ]] ; then
        echo "INFO: vhost0 is already up"
        ensure_host_resolv_conf
        return 0
    fi

    declare phys_int phys_int_mac addrs bind_type bind_int mtu routes
    if ! is_dpdk ; then
        # NIC case
        IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
        if [ -z "$BIND_INT" ] ; then
            # read from phys dev in non OSP case only
            addrs=$(get_addrs_for_nic $phys_int)
            mtu=$(get_iface_mtu $phys_int)
            routes=$(get_dev_routes $phys_int)
        fi
        echo "INFO: creating vhost0 for nic mode: nic: $phys_int, mac=$phys_int_mac"
        if ! create_vhost0 $phys_int $phys_int_mac ; then
            return 1
        fi
        bind_type='kernel'
        bind_int=$phys_int
    else
        # DPDK case
        if ! wait_dpdk_start ; then
            return 1
        fi
        local binding_data_dir='/var/run/vrouter'
        if [ ! -f "$binding_data_dir/nic" ] ; then
            echo "ERROR: there is not binding runtime information"
            return 1
        fi
        phys_int=`cat $binding_data_dir/nic`
        phys_int_mac=`cat $binding_data_dir/${phys_int}_mac`
        local pci_address=`cat $binding_data_dir/${phys_int}_pci`
        # TODO: This part of config is needed for vif tool to work,
        # later full config will be written.
        # Maybe rework someow config pathching..
        prepare_vif_config $AGENT_MODE
        addrs=`cat $binding_data_dir/${phys_int}_ip_addresses`
        mtu=`cat $binding_data_dir/${phys_int}_mtu`
        routes=`cat $binding_data_dir/${phys_int}_routes`
        echo "INFO: creating vhost0 for dpdk mode: nic: $phys_int, mac=$phys_int_mac"
        if ! create_vhost0_dpdk $phys_int $phys_int_mac ; then
            return 1
        fi
        bind_type='dpdk'
        bind_int=$pci_address
    fi

    local ret=0
    if [[ -e /etc/sysconfig/network-scripts/ifcfg-${phys_int} || -e /etc/sysconfig/network-scripts/ifcfg-vhost0 ]]; then
        echo "INFO: creating ifcfg-vhost0 and initialize it via ifup"
        if ! is_dpdk ; then
            ifdown ${phys_int}
            kill_dhcp_clients ${phys_int}
        fi
        if [ -z "$BIND_INT" ] ; then
            # Patch if it is not the case of OSP+DPDK (BIND_INT is set if 
            # dpdk container is started by ifup script, vhost0 is initialized here 
            # and ifcfg files are already prepared correctly by os-net-collect)
            prepare_ifcfg $phys_int $bind_type $bind_int || true
        fi
        if ! is_dpdk ; then
            ifup ${phys_int} || { echo "ERROR: failed to ifup $phys_int." && ret=1; }
        fi
        ip link set dev vhost0 down
        ifup vhost0 || { echo "ERROR: failed to ifup vhost0." && ret=1; }
        check_physical_mtu ${mtu} ${phys_int}
    else
        echo "INFO: there is no ifcfg-$phys_int and ifcfg-vhost0, so initialize vhost0 manually"
        if ! is_dpdk ; then
            # TODO: switch off dhcp on phys_int permanently
            kill_dhcp_clients ${phys_int}
        fi
        echo "INFO: Changing physical interface to vhost in ip table"
        echo "$addrs" | while IFS= read -r line ; do
            if ! is_dpdk ; then
                local addr_to_del=`echo $line | cut -d ' ' -f 1`
                ip address delete $addr_to_del dev $phys_int || { echo "ERROR: failed to del $addr_to_del from ${phys_int}." && ret=1; }
            fi
            local addr_to_add=`echo $line | sed 's/brd/broadcast/'`
            ip address add $addr_to_add dev vhost0 || { echo "ERROR: failed to add address $addr_to_add to vhost0." && ret=1; }
        done
        if [[ -n "$mtu" ]] ; then
            echo "INFO: set mtu"
            ip link set dev vhost0 mtu $mtu
        fi
        check_physical_mtu ${mtu} ${phys_int}
        set_dev_routes vhost0 "$routes"
    fi
    # Remove all routes from phys iface if any.
    # One case is centos: it may assign 192.254.0.0/16 to ethX as a Zeroconf route.
    # (/etc/sysconfig/network-scripts/ifup-eth)
    if ! is_dpdk ; then
        local _phys_int_routes=$(get_dev_routes $phys_int)
        del_dev_routes ${phys_int} "$_phys_int_routes"
    fi

    [[ $ret == 0 ]] && ensure_host_resolv_conf

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

function cleanup_lbaas_netns_config() {
    for netns in `ip netns 2>/dev/null | awk '/^vrouter-/{print $1}'`;do
        ip netns delete $netns
    done
    rm -rf /var/lib/contrail/loadbalancer/*
}

function cleanup_contrail_cni_config() {
    rm -f /opt/cni/bin/contrail-k8s-cni
    rm -f /etc/cni/net.d/10-contrail.conf
}

function cleanup_mesos_cni_config() {
    rm -f /opt/mesosphere/active/cni/contrail-cni-plugin
    rm -f /opt/mesosphere/etc/dcos/network/cni/contrail-cni-plugin.conf
}

# generic remove vhost functionality
function remove_vhost0() {
    if is_dpdk ; then
        # There is nothing to do in agent container for dpdk case
        # the interface is handled by dpdk container
        echo "INFO: removing vhost0 is skipped for dpdk"
        return
    fi
    echo "INFO: removing vhost0"
    declare phys_int phys_int_mac restore_ip_cmd routes
    IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
    local netscript_dir='/etc/sysconfig/network-scripts'
    if [ ! -d "$netscript_dir" ] ; then
        restore_ip_cmd=$(gen_ip_addr_add_cmd vhost0 $phys_int)
        routes=$(get_dev_routes vhost0)
        del_dev_routes vhost0 "$routes"
    fi
    remove_vhost0_kernel || { echo "ERROR: failed to remove vhost0" && return 1; }
    restore_phys_int $phys_int "$restore_ip_cmd" "$routes"
}

# Modify/Deletes files created by agent container
function cleanup_vrouter_agent_files() {
    # remove config file
    rm -rf /etc/contrail/contrail-vrouter-agent.conf
}

# terminate vrouter agent process
function term_process() {
    local pid=$1
    [ -z "$pid" ] && return
    if kill -0 $pid 2>&1 >/dev/null ; then
        echo "INFO: terminating process $pid"
        kill -KILL "$pid" &>/dev/null
        wait $pid
    fi
}

# send quit signal to root process
function quit_root_process() {
    kill -QUIT 1
}

# send SIGHUP signal to child process
function send_sighup_child_process(){
    local pid=$1
    [ -n "$pid" ] && kill -HUP "$pid"
}

# In release 5.0, vrouter to vrouter encryption
# works only on kernels 4.4 and above
function is_encryption_supported() {
    local enc="${VROUTER_ENCRYPTION:-TRUE}"
    if [[ "${enc^^}" == 'FALSE' ]]; then
        return 1
    fi
    local kernel_version=`uname -r | cut -d "-" -f 1`
    printf "${kernel_version}\n${REQUIRED_KERNEL_VROUTER_ENCRYPTION}" | sort -V | head -1 | grep -q $REQUIRED_KERNEL_VROUTER_ENCRYPTION
}

# create the ipvlan interface for
# vrouter to vrouter datapath encryption
function init_crypt0() {
    local crypt_intf=$1
    if ip link show $crypt_intf ; then
        echo "INFO: $crypt_intf already exists"
        return
    fi

    load_kernel_module ipvlan || { echo "ERROR: Failed to load ipvlan kernel module" && return 1; }
    if grep -q aes /proc/cpuinfo ; then
        load_kernel_module aesni_intel || echo "WARNING: Failed to load aesni_intel kernel module. Proceeding without aesni module."
    fi

    local mtu=`cat /sys/class/net/vhost0/mtu`
    mtu=$((mtu-60))
    ip link add $crypt_intf link vhost0 type ipvlan || { echo "ERROR: Failed to initialize ipvlan interface $crypt_intf" && return 1; }
    ip link set dev $crypt_intf mtu $mtu up
    echo "Successfully added ipvlan interface $crypt_intf"
}

function create_iptables_vrouter_encryption() {
    local key=$1
    # create iptables rule for marking the packets such that IPSec kernel can process such packets
    # UDP port 6635 - MPLSoUDP, 4789 - VXLAN
    if ! iptables -L -nvx -t mangle | grep -wq 6635 ; then
        iptables -I OUTPUT -t mangle -p udp --dport 6635 -j MARK --set-mark $key || echo "WARNING: Failed to add iptables rule for MPLS0UDP encryption"
    fi
    if ! iptables -L -nvx -t mangle | grep -wq 4789 ; then
        iptables -I OUTPUT -t mangle -p udp --dport 4789 -j MARK --set-mark $key || echo "WARNING: Failed to add iptables rule for VXLANoUDP encryption"
    fi
    if ! iptables -L -nvx -t mangle | grep -wq 47 ; then
        iptables -I OUTPUT -t mangle -p gre -j MARK --set-mark $key || echo "WARNING: Failed to add iptables rule for GRE encryption"
    fi
}

# create decrypt interface for vrouter
# to vrouter encryption
function init_decrypt0() {
    local decrypt_intf=$1
    local key=$2
    if ip link show $decrypt_intf ; then
        echo "INFO: $decrypt_intf already exists"
    else
        local mtu=`cat /sys/class/net/vhost0/mtu`
        local l_ip=$(get_ip_for_nic vhost0)
        ip tunnel add $decrypt_intf local $l_ip mode vti key $key || { echo "ERROR: Failed to initialize tunnel interface $decrypt_intf" && return 1; }
        ip link set dev $decrypt_intf mtu $mtu up
        echo "Successfully added tunnel interface $decrypt_intf and the required iptables rules"
    fi
    create_iptables_vrouter_encryption $key
}

# add the decrypt interface to vrouter
# this will be required till vrouter agent
# has the native support for decrrpt interface
function add_vrouter_decrypt_intf() {
    local decrypt_intf=$1
    local mac=$(get_iface_mac vhost0)
    if ip link show $decrypt_intf | grep -wq UP ; then
        # wait for vif to initialize
        sleep 2
        if ! vif --list | grep -wq $decrypt_intf ; then
            vif --add $decrypt_intf --mac $mac --vrf 0 --vhost-phys --type physical || { echo "ERROR: Failed to add decrypt interface $decrypt_intf to vrouter" && return 1; }
            echo "Successfully added tunnel interface $decrypt_intf to vrouter"
        fi
    fi
}

# this check is required for ensuring
# dhclp clients for vhost0 is running
# for the dhcp lease renewal
function check_vhost0_dhcp_clients() {
    local pids=$(ps -A -o pid,cmd|grep 'vhost-dhcp\|vhost0' | grep -v grep | awk '{print $1}')
    echo $pids
}

# sleeping for 3 seconds is more than sufficient for the job and connectivity
# reason for the sleeps here are for the DHCP response and populting the lease file
# and also for making sure the arp table is updated with the mac of the GW
function launch_dhcp_clients() {
    mkdir -p /var/lib/dhcp
    dhclient -v -1  -sf /vhost-dhcp.sh -cf /dhclient-vhost0.conf -pf /run/dhclient.vhost0.pid -lf /var/lib/dhcp/dhclient.vhost0.leases -I vhost0 2>&1 </dev/null & disown -h "$!"
    sleep 3
}

function check_and_launch_dhcp_clients() {
    declare phys_int phys_int_mac
    IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
    if launch_dhcp_clients ; then
       kill_dhcp_clients $phys_int
       ip addr flush $phys_int
       ensure_host_resolv_conf
    else
        echo "WARNING: dhcp clients not running for vhost0. If this is not static configuration, connectivity will be lost"
    fi
}

function add_k8s_pod_cidr_route() {
    local pod_cidr=${KUBERNETES_POD_SUBNETS:-"10.32.0.0/12"}
    ip route add $pod_cidr via $VROUTER_GATEWAY dev vhost0
}

function mask2cidr() {
  local nbits=0
  local IFS=.
  for dec in $1 ; do
        case $dec in
            255) let nbits+=8;;
            254) let nbits+=7;;
            252) let nbits+=6;;
            248) let nbits+=5;;
            240) let nbits+=4;;
            224) let nbits+=3;;
            192) let nbits+=2;;
            128) let nbits+=1;;
            0);;
            *) echo "Error: $dec is not recognised"; exit 1
        esac
  done
  echo "$nbits"
}

function check_physical_mtu() {
    # In case of DHCP, vhost0 takes over the DHCP and gets set with the
    # MTU as provided by the DHCP interface MTU option. However the physical
    # goes to the default MTU as it is not running DHCP anymore
    # to avoid descrepancies that leads to a lot of issues, it is best to
    # ensure the physical interface is also set to the same MTU as it was.
    local mtu=$1
    local phys_int=$2
    local mtu_after_vhost=$(cat "/sys/class/net/${phys_int}/mtu")
    if [ "$mtu_after_vhost" -ne "$mtu" ] ; then
       echo "INFO: reset MTU of $phys_int"
       ip link set dev $phys_int mtu $mtu
    fi
}
