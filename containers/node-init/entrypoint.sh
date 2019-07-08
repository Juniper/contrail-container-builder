#!/bin/bash

ret=0

/sysctl-init.sh || ret=1

/contrail-status-init.sh || ret=1

/certs-init.sh || ret=1

/files-init.sh || ret=1

/firewall.sh || ret=1

exit $ret
