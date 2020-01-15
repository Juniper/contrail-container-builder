#!/bin/bash
#get list of files
local utils_dir="/usr/share/contrail-utils"
for base_path in $(find $utils_dir/*py) ; do
    local py_filename=$(basename $base_path)
    local bin_filename=$(echo $py_filename | cut -d '.' -f1)
    echo "$py_filename $bin_filename"
    bin_path="/usr/bin"$bin_filename
    [ ! -f $bin_path ] && ln -s $py_filename $bin_filename && chmod +x $bin_path
done