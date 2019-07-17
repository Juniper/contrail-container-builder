#!/bin/bash

ret=0

/sysctl-init.sh || ret=1

/contrail-status-init.sh || ret=1

/certs-init.sh || ret=1

/files-init.sh || ret=1

/iptables-init.sh || ret=1

/contrail-tools-init.sh || ret=1

exit $ret
