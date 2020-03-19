#!/bin/bash -xe

my_file="$(readlink -e "$0")"
my_dir="$(dirname $my_file)"

source "$my_dir/../kernel-init-functions.sh"

# Define the dataset for testing
list_dirs_modules="/opt/contrail/vrouter-kernel-modules/3.10.0-229.el7.x86_64/vrouter.ko
/opt/contrail/vrouter-kernel-modules/3.10.0-514.el7.x86_64/vrouter.ko
/opt/contrail/vrouter-kernel-modules/3.10.0-1062.1.1.el7.x86_64/vrouter.ko
/opt/contrail/vrouter-kernel-modules/3.10.0-1062.9.1.el7.x86_64/vrouter.ko"

list_dirs_kernels="/lib/modules/3.10.0-327.el7.x86_64
/lib/modules/3.10.0-1062.el7.x86_64
/lib/modules/3.10.0-1062.1.1.el7.x86_64
/lib/modules/3.10.0-1062.1.2.el7.x86_64
/lib/modules/3.10.0-1062.7.1.el7.x86_64
/lib/modules/3.10.0-693.el7.x86_64
/lib/modules/3.10.0-862.el7.x86_64
/lib/modules/3.10.0-957.el7.x86_64
/lib/modules/3.10.0-1062.9.1.el7.x86_64
/lib/modules/3.10.0-1062.12.1.el7.x86_64"

declare -A RESULTS
unset -f enable_kernel_module
enable_kernel_module () {
  local s_dir="$1"
  local d_dir="$2"
  echo "For kernel $2 module $1 is proposed"
  RESULTS[$2]="$1"
}

# Running tested features
available_modules=$( get_lists_modules_versions "$list_dirs_modules" )
installed_kernels=$( get_lists_kernels_versions "$list_dirs_kernels" )
install_kernel_modules "$available_modules" "$installed_kernels"

# Check result

[[ "${RESULTS["3.10.0-327.el7.x86_64"]}" == '3.10.0-229.el7.x86_64' ]] || FAILED_KERNELS+=('3.10.0-327.el7.x86_64')
[[ "${RESULTS["3.10.0-693.el7.x86_64"]}" == '3.10.0-514.el7.x86_64' ]] || FAILED_KERNELS+=('3.10.0-693.el7.x86_64')
[[ "${RESULTS["3.10.0-862.el7.x86_64"]}" == '3.10.0-514.el7.x86_64' ]] || FAILED_KERNELS+=('3.10.0-862.el7.x86_64')
[[ "${RESULTS["3.10.0-957.el7.x86_64"]}" == '3.10.0-514.el7.x86_64' ]] || FAILED_KERNELS+=('3.10.0-957.el7.x86_64')
[[ "${RESULTS["3.10.0-1062.el7.x86_64"]}" == '3.10.0-514.el7.x86_64' ]] || FAILED_KERNELS+=('3.10.0-1062.el7.x86_64')
[[ "${RESULTS["3.10.0-1062.1.1.el7.x86_64"]}" == '3.10.0-1062.1.1.el7.x86_64' ]] || FAILED_KERNELS+=('3.10.0-1062.1.1.el7.x86_64')
[[ "${RESULTS["3.10.0-1062.1.2.el7.x86_64"]}" == '3.10.0-1062.1.1.el7.x86_64' ]] || FAILED_KERNELS+=('3.10.0-1062.1.2.el7.x86_64')
[[ "${RESULTS["3.10.0-1062.7.1.el7.x86_64"]}" == '3.10.0-1062.1.1.el7.x86_64' ]] || FAILED_KERNELS+=('3.10.0-1062.7.1.el7.x86_64')
[[ "${RESULTS["3.10.0-1062.9.1.el7.x86_64"]}" == '3.10.0-1062.9.1.el7.x86_64' ]] || FAILED_KERNELS+=('3.10.0-1062.9.1.el7.x86_64')
[[ "${RESULTS["3.10.0-1062.12.1.el7.x86_64"]}" == '3.10.0-1062.9.1.el7.x86_64' ]] || FAILED_KERNELS+=('3.10.0-1062.12.1.el7.x86_64')

# Report
set +x
if [ "${#FAILED_KERNELS[@]}" -ne '0' ] ; then
  echo "TEST FAILED!"
  echo "An inappropriate module is proposed for kernels:"
  for i in ${FAILED_KERNELS[*]} ; do
    echo "$i"
  done
  exit 1
else
  echo "TEST SUCCESS"
fi
