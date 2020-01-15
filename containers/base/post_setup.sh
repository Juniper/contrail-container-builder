#!/bin/bash
#get list of files
local utils_dir="/usr/share/contrail-utils"
if [[ -e "${utils_dir}" ]] ; then
    for base_path in $(find $utils_dir \( -name "*.py" -o -name "*.sh" \)) ; do
        local py_filename=$(basename $base_path)
        local bin_filename=$(echo $py_filename | cut -d '.' -f1)
        echo "$py_filename $bin_filename"
        bin_path="/usr/bin/"$bin_filename
        [ ! -f $bin_path ] && ln -s $py_filename $bin_filename
    done
fi
[ -e "/opt/contrail/bin/getifname.sh" ] && ln -s /opt/contrail/bin/getifname.sh /usr/bin/getifname
