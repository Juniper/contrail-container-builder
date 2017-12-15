#!/bin/bash
# Builds containers. Parses common.env to take CONTRAIL_REGISTRY, CONTRAIL_REPOSITORY, CONTRAIL_VERSION or takes them from
# environment.
# Parameters:
# path: relative path (from this directory) to module(s) for selective build, can be omitted to build all, "all" value can also be used. Example: controller/webui
# opts: extra parameters to pass to docker

my_file="$(readlink -e "$0")"
my_dir="$(dirname $my_file)"
source "$my_dir/../parse-env.sh"

path="$1"
shift
opts="$@"

echo 'Contrail version: '$version
echo 'OpenStack version: '$os_version
echo 'OpenStack subversion (minor package version): '$os_subversion
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
      | sed -e 's/\(^ARG CONTRAIL_REGISTRY=.*\)/#\1/' \
      -e 's/\(^ARG CONTRAIL_VERSION=.*\)/#\1/' \
      -e 's/\(^ARG OPENSTACK_VERSION=.*\)/#\1/' \
      -e 's/\(^ARG OPENSTACK_SUBVERSION=.*\)/#\1/' \
      -e "s/\$OPENSTACK_VERSION/$os_version/g" \
      -e "s/\$OPENSTACK_SUBVERSION/$os_subversion/g" \
      -e 's|^FROM ${CONTRAIL_REGISTRY}/\([^:]*\):${CONTRAIL_VERSION}-${OPENSTACK_VERSION}|FROM '${registry}'/\1:'${version}-${os_version}'|' \
      > $dir/Dockerfile.nofromargs
    int_opts="-f $dir/Dockerfile.nofromargs"
  fi
  local logfile='build-'$container_name'.log'
  docker build -t ${registry}'/'${container_name}:${version}-${os_version} \
    --build-arg CONTRAIL_VERSION=${version} \
    --build-arg OPENSTACK_VERSION=${os_version} \
    --build-arg OPENSTACK_SUBVERSION=${os_subversion} \
    --build-arg CONTRAIL_REGISTRY=${registry} \
    --build-arg REPOSITORY=${repository} \
    ${int_opts} ${opts} $dir |& tee $logfile
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    docker push ${registry}'/'${container_name}:${version}-${os_version} |& tee -a $logfile
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
  path="."
fi
echo "INFO: starting build from $my_dir with relative path $path"
pushd $my_dir
build_dir $path
popd
if [ $was_errors -ne 0 ]; then
  echo 'ERROR: Failed to build some containers, see log files'
  exit 1
fi
