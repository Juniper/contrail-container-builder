#!/bin/bash -e
set -o pipefail

[ "${DEBUG,,}" == "true" ] && set -x
scriptdir=$(realpath $(dirname "$0"))
repo_path=${repo_path:-"$scriptdir"}

get_list_targets () {
  local path="$1"
  find "$path" -type f -name "run-test.sh" | sed -e "s#${repo_path}/##g" -e 's#/tests/run-test.sh##g'
}

check_all_targets () {
  local repository_path="$1"
  local target
  local target_list
  target_list=$(get_list_targets "$repository_path")
  for target in $target_list ; do
    ${repository_path}/${target}/tests/run-test.sh || FAILED_TESTS+=($target)
  done
}

check_target () {
  local repository_path="$1"
  local target="$2"
  local container_name
  container_name=$( echo $target | awk -F "/" '{print $NF}' )
  ${repository_path}/${target}/tests/run-test.sh || FAILED_TESTS+=($target)
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
  check_all_targets "$repo_path"
  print_report
elif [ "$1" == 'list' ] ; then
  echo "Possible targets for tests:"
  echo "$possible_targets"
elif echo "$possible_targets" | grep -P "^$1$" ; then
  check_target "$repo_path" "$1"
  print_report
else
  echo "Usage:"
  echo "./run-tests.sh          - Run test for all containers"
  echo "./run-tests.sh list     - Get a list of containers ready to test"
  echo "./run-tests.sh <target> - Run test for specified container"
fi
