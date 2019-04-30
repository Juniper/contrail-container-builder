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

echo "INFO: Target platform: $LINUX_DISTR:$LINUX_DISTR_VER"
echo "INFO: Contrail version: $CONTRAIL_VERSION"
echo "INFO: Contrail registry: $CONTRAIL_REGISTRY"
echo "INFO: Contrail repository: $CONTRAIL_REPOSITORY"
echo "INFO: Contrail container tag: $CONTRAIL_CONTAINER_TAG"
echo "INFO: Contrail generic base extra rpms: $GENERAL_EXTRA_RPMS"
echo "INFO: Contrail base extra rpms: $BASE_EXTRA_RPMS"
echo "INFO: yum additional repos to enable: $YUM_ENABLE_REPOS"

if [ -n "$opts" ]; then
  echo "INFO: Options: $opts"
fi

docker_ver=$(docker -v | awk -F' ' '{print $3}' | sed 's/,//g')
echo "INFO: Docker version: $docker_ver"

was_errors=0
op='build'

function process_container() {
  local dir=${1%/}
  local docker_file=$2
  local exit_code=0
  if [[ $op == 'list' ]]; then
    echo "${dir#"./"}"
    return
  fi
  local container_name=`echo ${dir#"./"} | tr "/" "-"`
  local container_name="contrail-${container_name}"
  echo "INFO: Building $container_name"

  tag="${CONTRAIL_CONTAINER_TAG}"
  local build_arg_opts=''
  if [[ "$docker_ver" < '17.06' ]] ; then
    # old docker can't use ARG-s before FROM:
    # comment all ARG-s before FROM
    cat ${docker_file} | awk '{if(ncmt!=1 && $1=="ARG"){print("#"$0)}else{print($0)}; if($1=="FROM"){ncmt=1}}' > ${docker_file}.nofromargs
    # and then change FROM-s that uses ARG-s
    sed -i \
      -e "s|^FROM \${CONTRAIL_REGISTRY}/\([^:]*\):\${CONTRAIL_CONTAINER_TAG}|FROM ${CONTRAIL_REGISTRY}/\1:${tag}|" \
      -e "s|^FROM \$LINUX_DISTR:\$LINUX_DISTR_VER|FROM $LINUX_DISTR:$LINUX_DISTR_VER|" \
      ${docker_file}.nofromargs
    docker_file="${docker_file}.nofromargs"
  fi
  build_arg_opts+=" --build-arg CONTRAIL_REGISTRY=${CONTRAIL_REGISTRY}"
  build_arg_opts+=" --build-arg CONTRAIL_CONTAINER_TAG=${tag}"
  build_arg_opts+=" --build-arg LINUX_DISTR_VER=${LINUX_DISTR_VER}"
  build_arg_opts+=" --build-arg LINUX_DISTR=${LINUX_DISTR}"
  build_arg_opts+=" --build-arg GENERAL_EXTRA_RPMS=\"${GENERAL_EXTRA_RPMS}\""
  build_arg_opts+=" --build-arg BASE_EXTRA_RPMS=\"${BASE_EXTRA_RPMS}\""
  build_arg_opts+=" --build-arg YUM_ENABLE_REPOS=\"$YUM_ENABLE_REPOS\""
  build_arg_opts+=" --build-arg CONTAINER_NAME=${container_name}"

  if [[ -f ./$dir/.externals ]]; then
    local item=''
    for item in `cat ./$dir/.externals` ; do
      local src=`echo $item | cut -d ':' -f 1`
      local dst=`echo $item | cut -d ':' -f 2`
      rsync -rv --exclude $dst --exclude '__*' ./$dir/$src ./$dir/$dst
    done
  fi

  local logfile='build-'$container_name'.log'
  docker build -t ${CONTRAIL_REGISTRY}'/'${container_name}:${tag} \
               -t ${CONTRAIL_REGISTRY}'/'${container_name}:${OPENSTACK_VERSION}-${tag} \
    ${build_arg_opts} -f $docker_file ${opts} $dir |& tee $logfile
  exit_code=${PIPESTATUS[0]}
  if [ ${PIPESTATUS[0]} -eq 0 -a ${CONTRAIL_REGISTRY_PUSH} -eq 1 ]; then
    docker push ${CONTRAIL_REGISTRY}'/'${container_name}:${tag} |& tee -a $logfile
    exit_code=${PIPESTATUS[0]}
    # temporary workaround; to be removed when all other components switch to new tags
    docker push ${CONTRAIL_REGISTRY}'/'${container_name}:${OPENSTACK_VERSION}-${tag} |& tee -a $logfile
  fi
  if [ ${exit_code} -eq 0 ]; then
    rm $logfile
  fi
  if [ -f $logfile ]; then
    was_errors=1
  fi
}

function process_dir() {
  local dir=${1%/}
  local docker_file="$dir/Dockerfile"
  if [[ -f "$docker_file" ]] ; then
    process_container "$dir" "$docker_file"
    return
  fi
  for d in $(ls -d $dir/*/ 2>/dev/null); do
    if [[ $d != "./" && $d == */general-base* ]]; then
      process_dir $d
    fi
  done
  for d in $(ls -d $dir/*/ 2>/dev/null); do
    if [[ $d != "./" && $d == */base* ]]; then
      process_dir $d
    fi
  done
  for d in $(ls -d $dir/*/ 2>/dev/null); do
    if [[ $d != "./" && $d != *base* ]]; then
      process_dir $d
    fi
  done
}

function update_file() {
  local file=$1
  local new_content=$2
  local content_encoded=${3:-'false'}
  local file_md5=${file}.md5
  if [[ -f "$file" && -f "$file_md5" ]] ; then
    echo "INFO: $file and it's checksum "$file_md5" are exist, check them"
    local new_md5
    if [[ "$content_encoded" == 'true' ]] ; then
      new_md5=`echo "$new_content" | base64 --decode | md5sum | awk '{print($1)}'`
    else
      new_md5=`echo "$new_content" | md5sum | awk '{print($1)}'`
    fi
    local old_md5=`cat "$file_md5" | awk '{print($1)}'`
    if [[ "$old_md5" == "$new_md5" ]] ; then
      echo "INFO: content of $file is not changed"
      return
    fi
  fi
  echo "INFO: update $file and it's checksum $file_md5"
  if [[ "$content_encoded" == 'true' ]] ; then
    echo "$new_content" | base64 --decode > "$file"
  else
    echo "$new_content" > "$file"
  fi
  md5sum "$file" > "$file_md5"
}

function update_repos() {
  local repo_ext="$1"
  for rfile in $(ls $my_dir/../*.${repo_ext}.template) ; do
    templ=$(cat $rfile)
    content=$(eval "echo \"$templ\"")
    dfile=$(basename $rfile | sed 's/.template//')
    update_file "general-base/$dfile" "$content"
    # this is special case - image derived directly from ubuntu image
    update_file "vrouter/kernel-build-init/$dfile" "$content"
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

if [[ "$op" == 'build' ]]; then
  echo "INFO: prepare Contrail repo file in base image"
  update_repos "repo"
fi

process_dir $path

popd &>/dev/null

if [ $was_errors -ne 0 ]; then
  echo "ERROR: Failed to build some containers, see log files:"
  ls -l $my_dir/*.log
  exit 1
fi
