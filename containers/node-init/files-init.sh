#!/bin/bash -x

source /common.sh

# Copy RPM of puppet module into the provided folder
# for now it is used in case of OSP13 where this folder is
# bind to the host directory.
INSTALL_PUPPET=${INSTALL_PUPPET:-false}
INSTALL_PUPPET_DIR=${INSTALL_PUPPET_DIR:-'/tmp'}
if is_enabled "$INSTALL_PUPPET" ; then
  mkdir -p $INSTALL_PUPPET_DIR
  cp -f /contrail-tripleo-puppet*.rpm $INSTALL_PUPPET_DIR
fi

# some orchetrators configure other services to log into this dif, e.g. rabbit
# that are run under their users.
mkdir -p $LOG_DIR
chmod 777 $LOG_DIR
