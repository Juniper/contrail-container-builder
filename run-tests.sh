#!/bin/bash -e
set -o pipefail

[ "${DEBUG,,}" == "true" ] && set -x
scriptdir=$(realpath $(dirname "$0"))

repo_path=${repo_path:-"$scriptdir"}
logs_path=${logs_path:-"${repo_path}/logs"}
mkdir -p "$logs_path"

for unit_test in $( find "$repo_path" -type f -name "run-test.sh" ) ; do
  container_name=$( echo $unit_test | awk -F "/" '{print($(NF-3))}' )
  $unit_test 2>&1 | tee "${logs_path}/${container_name}.log" || FAILED_TESTS+=($container_name)
done

if [ "${#FAILED_TESTS[@]}" -ne '0' ] ; then
  echo "ERROR: Tests failed for containers:"
  for t in ${FAILED_TESTS[*]} ; do
    echo "$t"
  done
  exit 1
else
  echo "INFO: All containers tests are successful"
fi
