#!/bin/bash
touch /etc/dhcp/dhcpd.conf
touch /var/lib/dhcpd/dhcpd.leases

exec "$@"
