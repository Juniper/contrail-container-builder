#!/bin/bash
if [ ${1} = init ] ; then
  echo "SCRIPT INIT"
  cd /etc/dnsmasq
  python dnsmasq_lease_processing.py read
else
  if [ ${1} = del ] ; then
    echo "SCRIPT DELETE"
    cd /etc/dnsmasq
    python dnsmasq_lease_processing.py delete ${3}
  fi
  if [ ${1} = old ] || [ ${1} = add ] ; then
    echo "SCRIPT ADD"
    cd /etc/dnsmasq
    python dnsmasq_lease_processing.py write ${2} ${3} ${DNSMASQ_LEASE_EXPIRES}
  fi
fi
