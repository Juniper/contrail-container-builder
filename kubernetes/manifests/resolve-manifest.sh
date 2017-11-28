#!/bin/bash
# Instantiates yaml templates (like contrail-template.yaml) changing parameters to specific values taken from common.env.
# Takes yaml as a first argument and writes result to output.
# Usage example: resolve-manifest.sh contrail-template.yaml > contrail.yaml

manifest_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$manifest_dir" ]]; then manifest_dir="$PWD"; fi
source "$manifest_dir/../../parse-env.sh"

IFS=
yaml=$(sed -e 's/"/\\"/g' -e 's/\$/uUu/g' -e 's/{{ *\([^ }]\+\) *}}/$\1/g' $1)

eval echo \"$yaml\" | sed 's/uUu/$/g'
