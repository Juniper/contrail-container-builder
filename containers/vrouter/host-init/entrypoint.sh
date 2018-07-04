#!/bin/bash

# /lib/modules needs to be mounted.

yum --nogpgcheck -y install mlnx-ofed-kernel-only

exec $@
