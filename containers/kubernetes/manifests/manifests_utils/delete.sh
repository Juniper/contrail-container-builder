#!/bin/bash
# Deletes kubernetes contrail deployment specified by the temlate yaml, resolving it on the fly.
# If no template is specified, will default to standalone deployment template.
# Usage example: delete.sh contrail-tempate.yaml


manifest_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$manifest_dir" ]]; then manifest_dir="$PWD"; fi

template_file=${1:-$manifest_dir"/contrail-standalone-kubernetes.yaml"}

$manifest_dir/resolve-manifest.sh "$template_file" | kubectl delete -f -
