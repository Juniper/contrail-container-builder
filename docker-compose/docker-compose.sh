#!/bin/bash
#
# A helping wrapper for docker-compose to add in the current context required
# by docker-compose.yaml environment variables. The env-variables are
# based on a provided in the common.env in the repo root folder.
#
# Usage example: docker-compose.sh <cmd> <params>

if [[ -z "$@" ]] ; then
  docker-compose --help
  exit 0
fi

my_dir="${BASH_SOURCE%/*}"
source "$my_dir/../parse-env.sh"

if ! docker-compose config -q ; then
  echo "ERROR: docker-compose configuration is not valid"
  exit -1
fi
docker-compose $@
