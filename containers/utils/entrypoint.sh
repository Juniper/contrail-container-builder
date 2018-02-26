#!/bin/bash

source /common.sh

set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"
