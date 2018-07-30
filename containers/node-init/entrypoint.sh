#!/bin/bash -x

ret=0

/sysctl-init.sh || ret=1

/contrail-status-init.sh || ret=1

/certs-init.sh || ret=1

/files-init.sh || ret=1

exit $ret
