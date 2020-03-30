#!/bin/bash -e

source /common.sh

pre_start_init

# In all in one deployment there is the race between vhost0 initialization
# and own IP detection, so there is 10 retries
for i in {1..10} ; do
  # dnsmasq is a subordinate of device-manager that is placed in config pod.
  # thus we don't have nodes definitions for dnsmasq and for device-manager
  # and here we use CONFIG_NDOES
  my_ip_and_order=$(find_my_ip_and_order_for_node CONFIG)
  if [ -n "$my_ip_and_order" ]; then
    break
  fi
  sleep 1
done
if [ -z "$my_ip_and_order" ]; then
  echo "ERROR: Cannot find self ips ('$(get_local_ips)') in config nodes ('$CONFIG_NODES')"
  exit -1
fi
my_ord=$(echo $my_ip_and_order | cut -d ' ' -f 2)
# convert order to delay. order starts from 1 and it means 0, order=2 means delay 2 and further
my_ord=$((2*my_ord - 2))

cat > /etc/dnsmasq/base.conf << EOM
log-facility=${LOG_FOLDER_ABS_PATH}/dnsmasq.log
bogus-priv
log-dhcp
dhcp-reply-delay=${my_ord}
EOM
if ! is_enabled ${USE_EXTERNAL_TFTP} ; then
cat >> /etc/dnsmasq/base.conf << EOM
enable-tftp
tftp-root=/etc/tftp
EOM
fi

set_vnc_api_lib_ini

exec "$@"
