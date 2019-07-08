#!/bin/bash

source /common.sh

if is_enabled $CONFIGURE_FIREWALLD; then
  bash -x firewalld-init.sh
else
  bash -x iptables-init.sh
fi
