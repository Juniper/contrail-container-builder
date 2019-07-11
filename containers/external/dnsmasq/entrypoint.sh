#!/bin/bash -e

source /common.sh

cat > /etc/dnsmasq/base.conf << EOM
log-facility=${LOG_DIR}/dnsmasq.log
bogus-priv
log-dhcp
EOM
if ! is_enabled ${USE_EXTERNAL_TFTP} ; then
cat >> /etc/dnsmasq/base.conf << EOM
enable-tftp
tftp-root=/etc/tftp
EOM
fi

exec "$@"
