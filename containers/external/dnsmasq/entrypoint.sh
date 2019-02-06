#!/bin/bash -e

cat > /etc/dnsmasq/base.conf << EOM
log-facility=/var/log/contrail/dnsmasq.log
keep-in-foreground
bogus-priv
log-dhcp
EOM
if is_enabled ${ENABLE_TFTP} ; then
cat > /etc/dnsmasq/base.conf << EOM
enable-tftp
tftp-root=/etc/tftp
EOM
fi

cat /dev/null > /var/lib/dnsmasq/dnsmasq.leases

exec "$@"
