#!/bin/bash
containers_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$containers_dir/../parse-env.sh"

path=$1
opts=$2

echo 'Contrail version: '$version
echo 'Contrail registry: '$registry
echo 'Contrail repository: '$repository
if [ -n "$opts" ]; then
  echo 'Options: '$opts
fi

linux=$(awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"')
was_errors=0

build_container () {
  local dir=${1%/}
  local container_name=`echo ${dir#"./"} | tr "/" "-"`
  local container_name='contrail-'${container_name}
  echo 'Building '$container_name
  if [ $linux == "centos" ]; then
    cat $dir/Dockerfile \
      | sed -e 's/\(^ARG CONTRAIL_REGISTRY=.*\)/#\1/' -e 's/\(^ARG CONTRAIL_VERSION=.*\)/#\1/' \
      -e 's|^FROM ${CONTRAIL_REGISTRY}/\([^:]*\):${CONTRAIL_VERSION}|FROM '$registry'/\1:'$version'|' \
      > $dir/Dockerfile.nofromargs
    int_opts="-f $dir/Dockerfile.nofromargs"
  fi
  local logfile='build-'$container_name'.log'
  docker build -t ${registry}'/'${container_name}:${version} \
    --build-arg CONTRAIL_VERSION=${version} \
    --build-arg CONTRAIL_REGISTRY=${registry} \
    --build-arg REPOSITORY=${repository} \
    ${int_opts} ${opts} $dir |& tee $logfile
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    docker push ${registry}'/'${container_name}:${version} |& tee -a $logfile
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
      rm $logfile
    fi
  fi
  if [ -f $logfile ]; then
    was_errors=1
  fi
}

build_dir () {
  local dir=${1%/}
  if [ -f ${dir}/Dockerfile ]; then
    build_container $dir
    return
  fi
  for d in $(ls -d $dir/*/ 2>/dev/null); do
    if [[ $d != "./" && $d == */base* ]]; then
      build_dir $d
    fi
  done
  for d in $(ls -d $dir/*/ 2>/dev/null); do
    if [[ $d != "./" && $d != */base* ]]; then
      build_dir $d
    fi
  done
}

if [ -z $path ] || [ $path = 'all' ]; then
  path=$containers_dir
fi
build_dir $path
if [ $was_errors -ne 0 ]; then
  echo 'Failed to build some containers, see log files'
fi
