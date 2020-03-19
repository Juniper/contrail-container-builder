#!/bin/bash -e
set -o pipefail

[ "${DEBUG,,}" == "true" ] && set -x
scriptdir=$(realpath $(dirname "$0"))
repo_path=${repo_path:-"$scriptdir"}
logs_path=${logs_path:-"${repo_path}/logs"}
mkdir -p "$logs_path"

get_list_targets () {
  local path="$1"
  find "$path" -type f -name "run-test.sh" | sed -e "s#${repo_path}/##g" -e 's#/tests/run-test.sh##g'
}

check_all_targets () {
  local repository_path="$1"
  local log_dir="$2"
  local log_name
  local target
  local target_list
  target_list=$(get_list_targets "$repository_path")
  for target in $target_list ; do
    log_name=
    ${repository_path}/${target}/tests/run-test.sh 2>&1 | tee "${log_dir}/$(echo "$target" | tr '/' '-').log" || FAILED_TESTS+=($target)
  done
}

check_target () {
  local repository_path="$1"
  local log_dir="$2"
  local target="$3"
  local container_name
  container_name=$( echo $target | awk -F "/" '{print $NF}' )
  ${repository_path}/${target}/tests/run-test.sh 2>&1 | tee "${log_dir}/$(echo "$target" | tr '/' '-').log" || FAILED_TESTS+=($target)
}
print_report () {
  if [ "${#FAILED_TESTS[@]}" -ne '0' ] ; then
    echo "ERROR: Tests failed for containers:"
    for t in ${FAILED_TESTS[*]} ; do
      echo "$t"
    done
    exit 1
  else
    echo "INFO: All containers tests are successful"
  fi
}

possible_targets=$(get_list_targets "$repo_path")
if [ -z "${1+x}" ] ; then
  check_all_targets "$repo_path" "$logs_path"
  print_report
elif [ "$1" == 'list' ] ; then
  echo "Possible targets for tests:"
  echo "$possible_targets"
elif [[ "$1" = "$possible_targets" ]] ; then
  check_target "$repo_path" "$logs_path" "$1"
  print_report
else
  echo "Usage:"
  echo "./run-tests.sh          - Run test for all containers"
  echo "./run-tests.sh list     - Get a list of containers ready to test"
  echo "./run-tests.sh <target> - Run test for specified container"
fi
