#!/bin/bash


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
    if ! is_dpdk ; then
        # NIC case
        IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
        if [[ "$vrouter_cidr" == '' ]] ; then
            addrs=$(get_ips_for_nic $phys_int)
            local default_gw_metric=`get_default_gateway_for_nic_metric $phys_int`
            gateway=${VROUTER_GATEWAY:-"$default_gw_metric"}
        fi
        echo "INFO: creating vhost0 for nic mode: nic: $phys_int, mac=$phys_int_mac"
        if ! create_vhost0 $phys_int $phys_int_mac ; then
            return 1
        fi
    else
        # DPDK case
        # TODO: rework someow config pathching..
        if ! wait_dpdk_agent_start ; then
            return 1
        fi
        phys_int=`get_default_physical_iface`
        local binding_data_dir='/var/run/vrouter'
        phys_int_mac=`cat $binding_data_dir/${phys_int}_mac`
        local pci_address=`cat $binding_data_dir/${phys_int}_pci`
            cat << EOM > /etc/contrail/contrail-vrouter-agent.conf
[DEFAULT]
platform=${AGENT_MODE}
physical_interface_mac = $phys_int_mac
physical_interface_address = $pci_address
physical_uio_driver = ${DPDK_UIO_DRIVER}
EOM
        if [[ "$vrouter_cidr" == '' ]] ; then
            addrs=`cat $binding_data_dir/${phys_int}_ip_addresses`
            default_gateway="$(cat $binding_data_dir/${phys_int}_gateway)"
            gateway=${VROUTER_GATEWAY:-$default_gateway}
        fi
        echo "INFO: creating vhost0 for dpdk mode: nic: $phys_int, mac=$phys_int_mac"
        if ! create_vhost0_dpdk $phys_int $phys_int_mac ; then
            return
        fi
    fi

    if [[ -e /etc/sysconfig/network-scripts/ifcfg-${phys_int} ]]; then
        echo "INFO: creating ifcfg-vhost0 and initialize it via ifup"
        if ! is_dpdk ; then
            ifdown ${phys_int}
        fi
        pushd /etc/sysconfig/network-scripts/
        if [ ! -f "ifcfg-${phys_int}.contrail.org" ] ; then
            /bin/cp -f ifcfg-${phys_int} ifcfg-${phys_int}.contrail.org
        fi
        sed -ri "/(DEVICE|ONBOOT|NM_CONTROLLED)/! s/.*/#commented_by_contrail& /" ifcfg-${phys_int}
        if ! grep -q "^NM_CONTROLLED=no" ifcfg-${phys_int} ; then
            echo 'NM_CONTROLLED="no"' >> ifcfg-${phys-int}
        fi
        if [[ ! -f ifcfg-vhost0 ]] ; then
            sed "s/${phys_int}/vhost0/g" ifcfg-${phys_int}.contrail.org > ifcfg-vhost0
            if is_dpdk ; then
                sed -ri "/NM_CONTROLLED/ s/.*/#commented_by_contrail& /" ifcfg-vhost0
                echo 'NM_CONTROLLED="no"' >> ifcfg-vhost0
            fi
        fi
        popd
        if ! is_dpdk ; then
            ifup ${phys_int}
        fi
        ifup vhost0
        while IFS= read -r line ; do
            ip route del $line
        done < <(ip route sh | grep ${phys_int})
    else
        echo "INFO: there is no ifcfg-$phys_int, so initialize vhost0 manually"
        # TODO: switch off dhcp on phys_int
        echo "INFO: Changing physical interface to vhost in ip table"
        echo "$addrs" | while IFS= read -r line ; do
            if ! is_dpdk ; then
                addr_to_del=`echo $line | cut -d ' ' -f 1`
                ip address delete $addr_to_del dev $phys_int
            fi
            local addr_to_add=`echo $line | sed 's/brd/broadcast/'`
            ip address add $addr_to_add dev vhost0
        done
        if [[ -n "$gateway" ]]; then
            echo "INFO: set default gateway"
            ip route add default via $gateway
        fi
    fi
    if [ $(ps -efa | grep dhclient | grep -v grep | grep ${phys_int} |awk '{print $2}') ]; then
        kill -9 `ps -efa | grep dhclient | grep -v grep | grep ${phys_int} | awk '{print $2}'`
    fi
}
