#!/bin/bash

manifest_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$manifest_dir" ]]; then manifest_dir="$PWD"; fi

template_file=${1:-$manifest_dir"/contrail-template.yaml"}

$manifest_dir/resolve-manifest.sh "$template_file" | kubectl delete -f -
