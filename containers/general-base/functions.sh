#!/bin/bash

function get_linux_id() {
    awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"'
}

function get_linux_id_ver {
    local id=`get_linux_id`
    if [[ "$id" != 'ubuntu' ]] ; then
        # for ubuntu ver id matchs 7.4.1708, etc from host system
        awk '{print($4)}' /etc/redhat-release
    else
        # for ubuntu ver id matchs 14.04, 16.04, etc from host system
        awk -F '=' '/^VERSION_ID=/{print $2}' /etc/os-release | tr -d '"'
    fi
}

function is_centos() {
    test "$(get_linux_id)" == 'centos'
}

function is_rhel() {
    test "$(get_linux_id)" == 'rhel'
}

function is_ubuntu() {
    test "$(get_linux_id)" == 'ubuntu'
}

function is_ubuntu_xenial() {
    if ! is_ubuntu ; then
        return 1
    fi
    grep -qi 'xenial' /etc/lsb-release 2>/dev/null
}

function get_server_list() {
  local server_typ=$1_NODES
  local port_with_delim=$2
  local server_list=''
  IFS=',' read -ra server_list <<< "${!server_typ}"
  local extended_server_list=''
  for server in "${server_list[@]}"; do
    local server_address=`echo ${server}`
    extended_server_list+=${server_address}${port_with_delim}
  done
  local extended_list="${extended_server_list::-1}"
  echo ${extended_list}
}

function get_pci_address_for_nic() {
  local nic=$1
  ethtool -i ${nic} | grep bus-info | awk '{print $2}' | tr -d ' '
}

function get_default_nic() {
  ip route get 1 | grep -o "dev.*" | awk '{print $2}'
}

function get_cidr_for_nic() {
  local nic=$1
  ip addr show dev $nic | grep "inet .*/.* brd " | awk '{print $2}'
}

function get_ips_for_nic() {
    local nic=$1
    ip addr show dev $nic | grep "inet" | grep -oP "[0-9a-f\:\.]*/[0-9]* brd [0-9\.]*|[0-9a-f\:\.]*/[0-9]*"
}

function get_default_ip() {
  local nic=$(get_default_nic)
  get_cidr_for_nic $nic | cut -d '/' -f 1
}

function get_default_gateway_for_nic() {
  local nic=$1
  ip route show dev $nic | grep default | head -n 1 | awk '{print $3}'
}

function get_default_gateway_for_nic_metric() {
    local nic=$1
    local default_gw=`get_default_gateway_for_nic $nic`
    local default_gw_metric=`ip route show dev $nic | grep default | head -1 | grep -o "metric [0-9]*"`
    echo "$default_gw $default_gw_metric"
}

function find_my_ip_and_order_for_node() {
  local server_typ=$1_NODES
  local server_list=''
  IFS=',' read -ra server_list <<< "${!server_typ}"
  local local_ips=`ip addr | awk '/inet/ {print($2)}'`
  local ord=1
  for server in "${server_list[@]}"; do
    if [[ "$local_ips" =~ "$server" ]] ; then
      echo $server $ord
      return
    fi
    (( ord+=1 ))
  done
}

function get_vip_for_node() {
  local ip=$(find_my_ip_and_order_for_node $1 | cut -d ' ' -f 1)
  if [[ -z "$ip" ]] ; then
    local server_typ=$1_NODES
    ip=$(echo ${!server_typ} | cut -d',' -f 1)
  fi
  echo $ip
}

function get_listen_ip_for_node() {
  local ip=$(find_my_ip_and_order_for_node $1  | cut -d ' ' -f 1)
  if [[ -z "$ip" ]] ; then
    ip=$(get_default_ip)
  fi
  echo $ip
}

function get_order_for_node() {
  local order=$(find_my_ip_and_order_for_node $1 | cut -d ' ' -f 2)
  if [[ -z "$order" ]] ; then
    order=1
  fi
  echo $order
}

function get_default_physical_iface() {
  echo ${PHYSICAL_INTERFACE:-${DEFAULT_IFACE}}
}

function get_iface_mac() {
  local nic=$1
  cat /sys/class/net/${nic}/address
}

# It tries to resolve IP via local DBs (/etc/hosts, etc)
# if fails it then tries DNS lookup via the tool 'host'
function resolve_hostname_by_ip() {
  local ip=$1
  local
  local host_entry=$(getent hosts $ip | head -n 1)
  local name=''
  if  [ $? -eq 0 ] ; then
    name=$(echo $host_entry | awk '{print $2}' | awk -F '.' '{print $1}')
  else
    host_entry=$(host -4 $server)
    if [ $? -eq 0 ] ; then
      name=$(echo $host_entry | awk '{print $5}')
      name=${name::-1}
    fi
  fi
  if [[ "$name" != '' ]] ; then
    echo $name
  fi
}

# Generates a name by rule node-<ip>
# replacing '.' with '-' and sets it in the /etc/hosts
function generate_hostname_by_ip() {
  local ip=$1
  local name="node-"$(echo $srv | tr '.' '-')
  echo "$ip   $name" >> /etc/hosts
  echo $name
}

function get_hostname_by_ip() {
  local ip=$1
  local name=$(resolve_hostname_by_ip $ip)
  if [[ -z "$name" ]] ; then
    name=$(generate_hostname_for_ip $ip)
  fi
  echo $name
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
            echo "ERROR: unsupported agent mode"
            exit -1
        fi
    else
        # DPDK case, nic name is not exist, so set it to default
        nic=$(get_default_physical_iface)
    fi
  else
    # there is no vhost0 device, so set to default
    nic=$(get_default_physical_iface)
    mac=$(get_iface_mac $nic)
  fi
  # Ensure that nic & mac are not empty
  if [[ "$nic" == '' || "$mac" == '' ]] ; then
      echo "ERROR: either phys nic or mac is empty: phys_int='$nic' phys_int_mac='$mac'"
      exit -1
  fi
  echo $nic $mac
}

function is_dpdk() {
    test "$AGENT_MODE" == 'dpdk'
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

function wait_nic () {
    local nic=$1
    local probes=${2:-60}
    while (( probes > 0 )) ; do
        echo "INFO: Waiting for ${nic}... tries left $probes"
        if [[ -L /sys/class/net/${nic} ]] ; then
            return 0
        fi
        (( probes -= 1))
        sleep 2
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
function is_dpdk_agent_running() {
    netstat -ntl | awk '{print($4)}' | grep -q ':20914'
}

function wait_dpdk_agent_start() {
    local i=0
    for i in {1..60} ; do
        echo "INFO: wait DPDK agent to run... $i"
        if is_dpdk_agent_running ; then
            return 0
        fi
        sleep 5
    done
    return 1
}

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

function create_vhost0() {
    local phys_int=$1
    local phys_int_mac=$2
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
    ip link set dev vhost0 address $phys_int_mac
    ip link set dev vhost0 up
}

function create_vhost0_dpdk() {
    local phys_int=$1
    local phys_int_mac=$2
    # Check nic is not configured by agent
    if ! wait_nic vhost0 1 ; then
        echo "INFO: interface vhost0 does not exist.. try tro create"
        # vhost0 is not present, so create vhost0 and $dev
        echo "INFO: Creating ${phys_int} interface with mac $phys_int_mac via vif utility..."
        if ! vif --add 0 --mac ${phys_int_mac} --vrf 0 --vhost-phys --type physical --pmd --id 0 ; then
            echo "ERROR: Failed to adding ${phys_int} interface"
            return 1
        fi
        echo "INFO: Adding vhost0 interface with vif utility..."
        # TODO: vif --xconnect seems does not work without --id parameter?
        if ! vif --add vhost0 --mac ${phys_int_mac} --vrf 0 --type vhost --xconnect 0 --pmd --id 1 ; then
            echo "ERROR: Failed to add vhost0 interface"
            return 1
        fi
    fi
    if ! ip link set dev vhost0 address $phys_int_mac ; then
        echo "ERROR: Failed to set vhost0 address $phys_int_mac"
        return 1
    fi
    if ! ip link set dev vhost0 up ; then
        echo "ERROR: Failed to up vhost0 interface"
        return 1
    fi
}

function save_pci_info() {
    local nic=$1
    local pci_address=$2
    local binding_data_dir='/var/run/vrouter'
    mkdir -p ${binding_data_dir}
    local binding_data_file="${binding_data_dir}/${pci_address}"
    if [[ ! -e "$binding_data_file" ]] ; then
        local pci_data=`lspci -vmmks ${pci_address}`
        echo "INFO: Add lspci data to ${binding_data_file}"
        echo "$pci_data"
        echo "$pci_data" > ${binding_data_file}
    else
        echo "INFO: lspci data for $pci_address already exists"
    fi
}

function bind_devs_to_driver() {
    local driver=$1
    shift 1
    local nics=( $@ )
    # bind physical device(s) to DPDK driver
    local ret=0
    local n=''
    for n in ${nics[@]} ; do
        echo "INFO: Binding device $n to driver $driver ..."
        local pci_address=`get_pci_address_for_nic $n`
        save_pci_info $n $pci_address
        if ! /opt/contrail/bin/dpdk_nic_bind.py --force --bind="$driver" $n ; then
            echo "ERROR: Failed to bind $n to driver $driver"
            exit -1
        fi
        if ! wait_device_for_driver $driver $pci_address ; then
            echo "ERROR: Failed to wait device $n ($pci_address) to appears for driver $driver"
            exit -1
        fi
    done
}

function restore_bindinds() {
    # TODO: most probably remove this function since it is not used
    local binding_data_dir='/var/run/vrouter'
    if [[ ! -d "$binding_data_dir" ]] ; then
        ehoc "INFO: there is no local data with devs bound to dpdk uio"
        return 0
    fi
    local dev=''
    for dev in `ls "$binding_data_dir" | grep '^[0-9]\{4\}:[0-9]\{2\}'` ; do
        local driver=`awk '/Driver:/ {print($2)}' "$binding_data_dir/$dev"`
        echo "INFO: Binding device $dev to default driver $driver..."
        if ! /opt/contrail/bin/dpdk_nic_bind.py --force --bind=$driver $dev ; then
            echo "WARNING: Failed to bind $dev to driver $driver. Probable it already bind."
        fi
        # remove binding data
        rm -f $binding_data_dir/$dev
        local nic=`ls "/sys/bus/pci/drivers/$driver/$dev/net"`
        if [[ -z "$nic" ]] ; then
            echo "WARNING: there is no path /sys/bus/pci/drivers/$driver/$dev/net, skip re-init device."
            continue
        fi
        if ! wait_nic $nic ; then
            echo "WARNING: there is no $nic device, skip re-init device."
            continue
        fi
        ip link set dev $nic down || echo "INFO: $nic is already down"
        ip link set dev $nic up || echo "WARNING: failed to up interface $nic"
    done
}

function ensure_hugepages() {
    local hp_dir=${1:?}
    if [[ ! -d "$hp_dir" ]] ; then
        echo "WARNING: There is no $hp_dir mounted from host. Try to create and mount hugetlbfs."
        if ! mkdir -p $hp_dir ; then
            echo "ERROR: failed to create $hp_dir"
            exit -1
        fi
        if ! mount -t hugetlbfs hugetlbfs $hp_dir ; then
            echo "ERROR: failed to mount hugetlbfs to $hp_dir"
            exit -1
        fi
    fi

    if [[ ! -d "$hp_dir" ]]  ; then
        echo "ERROR: There is no $hp_dir. Probably HugeTables are anuvailable on the host."
        exit -1
    fi
}

function set_ctl() {
    local var=$1
    local value=$2
    if grep -q "^$var" /etc/sysctl.conf ; then
        sed -i "s/^$var.*=.*/$var=$value/g"  /etc/sysctl.conf
    else
        echo "$var=$value" >> /etc/sysctl.conf
    fi
    sysctl -w ${var}=${value}
}

function load_kernel_module() {
    local module=$1
    shift 1
    local opts=$@
    echo "INFO: load $module kernel module"
    if ! modprobe -v "$module" $opts ; then
        echo "ERROR: failed to load $module driver"
        exit -1
    fi
}

function unload_kernel_module() {
    local module=$1
    echo "INFO: unload $module kernel module"
    if ! rmmod $module ; then
        echo "WARNING: Failed to unload $module driver"
    fi
}
