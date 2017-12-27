#!/bin/bash
# Down contrail cluser with resolving variables from common.env
# Usage example: down.sh

my_dir="${BASH_SOURCE%/*}"
$my_dir/docker-compose.sh down $@
