#!/bin/bash
set -x
build_root_size=${#build_root}
function is_elf() {
  [[ 'ELF' == "$(dd if=$1 count=3 bs=1 skip=1 2>/dev/null)" ]]
}

function strip_file() {
  local file=$1
  is_elf $file &&  strip --strip-unneeded -p $file
}

vrouter_paths=$( find ${build_root}/BUILDROOT/contrail-vrouter-[0-9][0-9][0-9][0-9]*.x86_64/opt/contrail/vrouter-kernel-modules/*/vrouter.ko )
echo "We are going to copy files from $vrouter_paths"
for vrouter_src in $vrouter_paths; do
    k_ver=$( echo "${vrouter_src:$build_root_size}" | awk -F '/' '{ print $6 }' )
    echo "The kernel version is $k_ver"
    $vrouter_dst="/opt/contrail/vrouter-kernel-modules/${k_ver}/vrouter.ko"
    strip_file $vrouter_src
    cp -ap $vrouter_src $vrouter_dst
    exitcode=${PIPESTATUS[0]}
    if [[ $exitcode -ne 0 ]]; then
      log "Copying of vrouter.ko file from ${vrouter_src} to ${vrouter_dst} finished with error"
      exit 1
    fi    
done
set +x