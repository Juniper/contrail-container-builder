#!/bin/bash
# Applies specified or default template to kubernetes, resolving it on the fly.
# Default template will be the one for standalone deployment model.
# Usage example: apply.sh contrail-tempate.yaml

manifest_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$manifest_dir" ]]; then manifest_dir="$PWD"; fi

template_file=${1:-$manifest_dir"/contrail-standalone-kubernetes.yaml"}

$manifest_dir/resolve-manifest.sh "$template_file" | kubectl apply -f -
