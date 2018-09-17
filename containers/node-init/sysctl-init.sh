#!/bin/bash

source /common.sh

# configure core_pattern for Host OS
set_ctl kernel.core_pattern /var/crashes/core.%e.%p.%h.%t
