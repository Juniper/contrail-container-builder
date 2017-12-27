#!/bin/bash
# Up contrail cluser with resolving variables from common.env
# Usage example: up.sh

my_dir="${BASH_SOURCE%/*}"
$my_dir/docker-compose.sh up -d $@
