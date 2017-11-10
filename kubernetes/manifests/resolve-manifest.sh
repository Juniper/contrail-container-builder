#!/bin/bash

manifest_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$manifest_dir" ]]; then manifest_dir="$PWD"; fi
source "$manifest_dir/../../parse-env.sh"

IFS=
yaml=$(sed -e 's/"/\\"/g' -e 's/$\([0-9a-zA-Z_]\+\)/uUu\1/g' -e 's/{{ *\([^ }]\+ *\)}}/$\1/g' $1)

eval echo \"$yaml\" | sed 's/uUu\([0-9a-zA-Z_]\+\)/$\1/g'
