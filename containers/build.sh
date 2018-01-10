#!/bin/bash
# Builds containers. Parses common.env to take CONTRAIL_REGISTRY, CONTRAIL_REPOSITORY, CONTRAIL_VERSION or takes them from
# environment.
# Parameters:
# path: relative path (from this directory) to module(s) for selective build. Example: ./build.sh controller/webui
#   if it's omitted then script will build all
#   "all" as argument means build all. It's needed if you want to build all and pass some docker opts (see below).
#   "list" will list all relative paths for build in right order. It's needed for automation. Example: ./build.sh list | grep -v "^INFO:"
# opts: extra parameters to pass to docker. If you want to pass docker opts you have to specify 'all' as first param (see 'path' argument above)

my_file="$(readlink -e "$0")"
my_dir="$(dirname $my_file)"
source "$my_dir/../parse-env.sh"

path="$1"
shift
opts="$@"

echo "INFO: Linux: $LINUX_DISTR:$LINUX_DISTR_VER"
echo "INFO: Contrail version: $CONTRAIL_VERSION"
echo "INFO: OpenStack version: $OPENSTACK_VERSION"
echo "INFO: OpenStack subversion (minor package version): $OS_SUBVERSION"
echo "INFO: Contrail registry: $CONTRAIL_REGISTRY"
echo "INFO: Contrail repository: $CONTRAIL_REPOSITORY"
if [ -n "$opts" ]; then
  echo "INFO: Options: $opts"
fi

docker_ver=$(docker -v | awk -F' ' '{print $3}' | sed 's/,//g')
echo "INFO: Docker version: $docker_ver"

was_errors=0
op='build'

process_container () {
  local dir=${1%/}
  local docker_file=$2
  if [[ $op == 'list' ]]; then
    echo "${dir#"./"}"
    return
  fi
  local container_name=`echo ${dir#"./"} | tr "/" "-"`
  local container_name="contrail-${container_name}"
  echo "INFO: Building $container_name"
  local build_arg_opts=''
  if [[ "$docker_ver" < '17.06' ]] ; then
    cat $docker_file \
      | sed -e 's/\(^ARG CONTRAIL_REGISTRY=.*\)/#\1/' \
      -e 's/\(^ARG CONTRAIL_VERSION=.*\)/#\1/' \
      -e 's/\(^ARG OPENSTACK_VERSION=.*\)/#\1/' \
      -e 's/\(^ARG OPENSTACK_SUBVERSION=.*\)/#\1/' \
      -e 's/\(^ARG LINUX_DISTR_VER=.*\)/#\1/' \
      -e 's/\(^ARG LINUX_DISTR=.*\)/#\1/' \
      -e "s/\$OPENSTACK_VERSION/$OPENSTACK_VERSION/g" \
      -e "s/\$OPENSTACK_SUBVERSION/$OS_SUBVERSION/g" \
      -e "s/\$LINUX_DISTR_VER/$LINUX_DISTR_VER/g" \
      -e "s/\$LINUX_DISTR/$LINUX_DISTR/g" \
      -e 's|^FROM ${CONTRAIL_REGISTRY}/\([^:]*\):${CONTRAIL_VERSION}-${LINUX_DISTR}-${OPENSTACK_VERSION}|FROM '${CONTRAIL_REGISTRY}'/\1:'${CONTRAIL_VERSION}-${LINUX_DISTR}-${OPENSTACK_VERSION}'|' \
      > ${docker_file}.nofromargs
    docker_file="${docker_file}.nofromargs"
  else
    build_arg_opts+=" --build-arg CONTRAIL_VERSION=${CONTRAIL_VERSION}"
    build_arg_opts+=" --build-arg OPENSTACK_VERSION=${OPENSTACK_VERSION}"
    build_arg_opts+=" --build-arg OPENSTACK_SUBVERSION=${OS_SUBVERSION}"
    build_arg_opts+=" --build-arg CONTRAIL_REGISTRY=${CONTRAIL_REGISTRY}"
    build_arg_opts+=" --build-arg LINUX_DISTR_VER=${LINUX_DISTR_VER}"
    build_arg_opts+=" --build-arg LINUX_DISTR=${LINUX_DISTR}"
  fi

  local logfile='build-'$container_name'.log'
  docker build -t ${CONTRAIL_REGISTRY}'/'${container_name}:${CONTRAIL_VERSION}-${LINUX_DISTR}-${OPENSTACK_VERSION} \
    ${build_arg_opts} -f $docker_file ${opts} $dir |& tee $logfile
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    docker push ${CONTRAIL_REGISTRY}'/'${container_name}:${CONTRAIL_VERSION}-${LINUX_DISTR}-${OPENSTACK_VERSION} |& tee -a $logfile
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
      rm $logfile
    fi
  fi
  if [ -f $logfile ]; then
    was_errors=1
  fi
}

process_dir () {
  local dir=${1%/}
  local docker_file="$dir/Dockerfile"
  local docker_file_ld="$docker_file.$LINUX_DISTR"
  if [[ -f "$docker_file" || -f "$docker_file_ld" ]] ; then
    local df=$docker_file_ld
    if [[ ! -f "$df" ]] ; then
      df=$docker_file
    fi
    process_container "$dir" "$df"
    return
  fi
  for d in $(ls -d $dir/*/ 2>/dev/null); do
    if [[ $d != "./" && $d == */base* ]]; then
      process_dir $d
    fi
  done
  for d in $(ls -d $dir/*/ 2>/dev/null); do
    if [[ $d != "./" && $d != */base* ]]; then
      process_dir $d
    fi
  done
}

if [[ $path == 'list' ]] ; then
  op='list'
  path="."
fi

if [ -z $path ] || [ $path = 'all' ]; then
  path="."
fi

echo "INFO: starting build from $my_dir with relative path $path"
pushd $my_dir &>/dev/null

echo "INFO: prepare Contrail repo file in base image"
repo_template=$(sed 's/\(.*\){{ *\(.*\) *}}\(.*\)/\1$\2\3/g' $my_dir/../contrail.repo.template)
repo_content=$(eval "echo \"$repo_template\"")
update_contrail_repo='true'
if [[ -f base/contrail.repo && -f base/contrail.repo.md5 ]] ; then
  echo "INFO: base/contrail.repo and its checksum are exist, check them"
  new_repo_md5=$(echo "$repo_content" | md5sum | awk '{print($1)}')
  old_repo_md5=$(cat base/contrail.repo.md5 | awk '{print($1)}')
  if [[ "$old_repo_md5" == "$new_repo_md5" ]] ; then
    echo "INFO: content of contrail.repo is not changed"
    update_contrail_repo='false'
  fi
fi
if [[ "$update_contrail_repo" == 'true' ]] ; then
  echo "$repo_content" > base/contrail.repo
  md5sum base/contrail.repo > base/contrail.repo.md5
fi
process_dir $path

popd &>/dev/null

if [ $was_errors -ne 0 ]; then
  echo "ERROR: Failed to build some containers, see log files"
  exit 1
fi
