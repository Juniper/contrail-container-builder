#!/bin/bash

source /common.sh

if [[ ! is_enabled ${APPLY_DEFAULTS} ]]; then
  exit 0
fi

pre_start_init

# Env variables:
# NODE_TYPE = name of the component [vrouter, config, control, analytics, database, config-database, toragent]

set_vnc_api_lib_ini

if is_enabled ${MAINTENANCE_MODE} ; then
  echo "WARNING: MAINTENANCE_MODE is switched on - provision.sh is not called."
elif ! /provision.sh ; then
  echo "ERROR: provision.sh was failed. Exiting..."
  exit 1
fi

tail -f /dev/null
