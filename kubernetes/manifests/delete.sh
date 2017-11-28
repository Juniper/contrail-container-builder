#!/bin/bash
# Deletes kubernetes contrail deployment specified by the temlate yaml, resolving it on the fly.
# Usage example: delete.sh contrail-tempate.yaml


manifest_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$manifest_dir" ]]; then manifest_dir="$PWD"; fi

template_file=${1:-$manifest_dir"/contrail-template.yaml"}

$manifest_dir/resolve-manifest.sh "$template_file" | kubectl delete -f -
