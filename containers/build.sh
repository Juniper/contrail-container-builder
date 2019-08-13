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

function log() {
  echo -e "$(date -u +"%Y-%m-%d %H:%M:%S,%3N"): INFO: $@"
}

function err() {
  echo -e "$(date -u +"%Y-%m-%d %H:%M:%S,%3N"): ERROR: $@" >&2
}

function append_log_file() {
  local logfile=$1
  local always_echo=${2:-'false'}
  local line=''
  while read line ; do
    if [[ "${CONTRAIL_KEEP_LOG_FILES,,}" != 'true' || "$always_echo" != 'false' ]] ; then
      echo "$line" | tee -a $logfile
    else
      echo "$line" >> $logfile
    fi
  done
}

log "Target platform: $LINUX_DISTR:$LINUX_DISTR_VER"
[ -n "$SRC_MOUNTED" ] && log "Contrail source root: $CONTRAIL_SOURCE"
log "Contrail version: $CONTRAIL_VERSION"
log "Contrail registry: $CONTRAIL_REGISTRY"
log "Contrail repository: $CONTRAIL_REPOSITORY"
log "Contrail container tag: $CONTRAIL_CONTAINER_TAG"
log "Contrail generic base extra rpms: $GENERAL_EXTRA_RPMS"
log "Contrail base extra rpms: $BASE_EXTRA_RPMS"
log "yum additional repos to enable: $YUM_ENABLE_REPOS"
log "Parallel build: $CONTRAIL_PARALLEL_BUILD"
log "Keep log files: $CONTRAIL_KEEP_LOG_FILES"
log "Vendor: $VENDOR_NAME"
log "Vendor Domain: $VENDOR_DOMAIN"

if [ -n "$opts" ]; then
  log "Options: $opts"
fi

docker_ver=$(docker -v | awk -F' ' '{print $3}' | sed 's/,//g')
log "Docker version: $docker_ver"

was_errors=0
if [[ "${CONTRAIL_PARALLEL_BUILD,,}" == 'true' ]] ; then
  op='build_parallel'
else
  op='build'
fi

function process_container() {
  local dir=${1%/}
  local docker_file=$2
  local exit_code=0
  if [[ $op == 'list' ]]; then
    echo "${dir#"./"}"
    return
  fi
  local start_time=$(date +"%s")
  local container_name=`echo ${dir#"./"} | tr "/" "-"`
  local container_name="contrail-${container_name}"
  local tag="${CONTRAIL_CONTAINER_TAG}"

  local logfile='build-'$container_name'.log'
  log "Building $container_name" | append_log_file $logfile true

  if [[ -f ./$dir/.externals ]]; then
    local item=''
    for item in `cat ./$dir/.externals` ; do
      local src=`echo $item | cut -d ':' -f 1`
      local dst=`echo $item | cut -d ':' -f 2`
      [[ -z "$src" || -z "$dst" ]] && continue
      rsync -r --exclude $dst --exclude-from='../.gitignore' ./$dir/$src ./$dir/$dst 2>&1 | append_log_file $logfile
    done
  fi

  local name_upper_case="$(echo ${container_name^^} | tr '-' '_')_BASE"
  local custom_base_name=${!name_upper_case}
  if [ -n "$custom_base_name" ] ; then
    # add tag if missed in custom base
    if ! echo "$custom_base_name" | grep -q ':' ; then
      custom_base_name="${custom_base_name}:${tag}"
    fi
    # add registry if missed in custom base
    if ! echo "$custom_base_name" | grep -q '/' ; then
      custom_base_name="${CONTRAIL_REGISTRY}/${custom_base_name}"
    fi
    log "Use custom base image $custom_base_name" | append_log_file $logfile true
    cat ${docker_file} | sed -e "s|^FROM.*|FROM $custom_base_name|" > ${docker_file}.custom
    docker_file="${docker_file}.custom"
  fi
  
  if [[ "$docker_ver" < '17.06' ]] ; then
    # old docker can't use ARG-s before FROM:
    # comment all ARG-s before FROM
    cat ${docker_file} | awk '{if(ncmt!=1 && $1=="ARG"){print("#"$0)}else{print($0)}; if($1=="FROM"){ncmt=1}}' > ${docker_file}.nofromargs
    # and then change FROM-s that uses ARG-s
    sed -i \
      -e "s|^FROM \${CONTRAIL_REGISTRY}/\([^:]*\):\${CONTRAIL_CONTAINER_TAG}|FROM ${CONTRAIL_REGISTRY}/\1:${tag}|" \
      -e "s|^FROM \$LINUX_DISTR:\$LINUX_DISTR_VER|FROM $LINUX_DISTR:$LINUX_DISTR_VER|" \
      -e "s|^FROM \$UBUNTU_DISTR:\$UBUNTU_DISTR_VERSION|FROM $UBUNTU_DISTR:$UBUNTU_DISTR_VERSION|" \
      ${docker_file}.nofromargs
    docker_file="${docker_file}.nofromargs"
  fi

  local build_arg_opts=''
  build_arg_opts+=" --build-arg CONTRAIL_REGISTRY=${CONTRAIL_REGISTRY}"
  build_arg_opts+=" --build-arg CONTRAIL_CONTAINER_TAG=${tag}"
  build_arg_opts+=" --build-arg LINUX_DISTR_VER=${LINUX_DISTR_VER}"
  build_arg_opts+=" --build-arg LINUX_DISTR=${LINUX_DISTR}"
  build_arg_opts+=" --build-arg GENERAL_EXTRA_RPMS=\"${GENERAL_EXTRA_RPMS}\""
  build_arg_opts+=" --build-arg BASE_EXTRA_RPMS=\"${BASE_EXTRA_RPMS}\""
  build_arg_opts+=" --build-arg YUM_ENABLE_REPOS=\"$YUM_ENABLE_REPOS\""
  build_arg_opts+=" --build-arg CONTAINER_NAME=${container_name}"
  build_arg_opts+=" --build-arg UBUNTU_DISTR_VERSION=${UBUNTU_DISTR_VERSION}"
  build_arg_opts+=" --build-arg UBUNTU_DISTR=${UBUNTU_DISTR}"
  build_arg_opts+=" --build-arg VENDOR_NAME=${VENDOR_NAME}"
  build_arg_opts+=" --build-arg VENDOR_DOMAIN=${VENDOR_DOMAIN}"

  # For setup from RPMs: add appropriate args to install RPMs
  # TODO: it is to be removed after complete switching to setup from sources
  if [[ -z "$SRC_MOUNTED" && -e ./$dir/.rpm ]]; then
    local rpm_items=''
    rpm_items=$(cat ./$dir/.rpm | sed '/^$/d' | tr '\n' ',')
    [ -n "$rpm_items" ] && build_arg_opts+=" --build-arg CONTRAIL_RPMS=\"${rpm_items}\""
  fi

  # For setup from sources: base dependencies (rpms) to avoid 
  # installing them from pip during python setup.py
  if [[ -e ./$dir/.deps || -e ./$dir/.deps.$LINUX_DISTR ]]; then
    local deps_items=''
    [ -e ./$dir/.deps ] && deps_items+=$(cat ./$dir/.deps)
    [ -e ./$dir/.deps.$LINUX_DISTR ] && deps_items+="\n$(cat ./$dir/.deps.$LINUX_DISTR)"
    deps_items=$(echo -e "$deps_items" | sed '/^$/d' | sort | uniq | tr '\n' ',')
    deps_items=${deps_items%%//,}
    deps_items=${deps_items##//,}
    [ -n "$deps_items" ] && build_arg_opts+=" --build-arg CONTRAIL_DEPS=\"${deps_items}\""
  fi

  log "Building args: $build_arg_opts" | append_log_file $logfile true
  docker build --network host -t ${CONTRAIL_REGISTRY}'/'${container_name}:${tag} \
    -t ${CONTRAIL_REGISTRY}'/'${container_name}:${OPENSTACK_VERSION}-${tag} \
    ${build_arg_opts} -f $docker_file ${opts} $dir 2>&1 | append_log_file $logfile
  exit_code=${PIPESTATUS[0]}
  local duration=$(date +"%s")
  (( duration -= start_time ))
  log "Docker build duration: $duration seconds" | append_log_file $logfile

  if [ ${exit_code} -eq 0 ]; then
    if [[ -n "$SRC_MOUNTED" && -e ./$dir/setup.sh ]] ; then
      # Setup from source
      # RHEL has old docker that doesnt support neither staged build nor mount option
      # 'RUN --mount' (still experimental at the moment of writting this comment).
      # So, ther is WA: previously build image is empty w/o RPMs but with all 
      # other stuff required, so, now the final step to run a intermediate container,
      # install components inside and commit is as the final image.
      local base_image="${CONTRAIL_REGISTRY}'/'${container_name}:${tag}"
      local cmd=$(docker inspect -f "{{json .Config.Cmd }}" $base_image)
      local entrypoint=$(docker inspect -f "{{json .Config.Entrypoint }}" $base_image)
      local intermediate_base="${container_name}_src"
      local src_items=''
      if [[ -e ./$dir/.src ]]; then
        src_items=$(cat ./$dir/.src | sed '/^$/d' | tr '\n' ',')
      fi
      docker run --name $intermediate_base --network host \
        -e "CONTRAIL_SOURCE=${CONTRAIL_SOURCE}" \
        -e "CONTRAIL_COMPONENTS=${src_items}" \
        -v ${CONTRAIL_SOURCE}:${CONTRAIL_SOURCE} \
        --entrypoint /setup.sh \
        $base_image 2>&1 | append_log_file $logfile
      exit_code=${PIPESTATUS[0]}
      if [ ${exit_code} -eq 0 ]; then
        docker commit \
          --change "CMD $cmd" \
          --change "ENTRYPOINT $entrypoint" \
          $intermediate_base $intermediate_base 2>&1 | append_log_file $logfile
        exit_code=${PIPESTATUS[0]}
        # retag containers
        [ ${exit_code} -eq 0 ] && docker tag $intermediate_base ${CONTRAIL_REGISTRY}'/'${container_name}:${tag} || exit_code=1
        [ ${exit_code} -eq 0 ] && docker tag $intermediate_base ${CONTRAIL_REGISTRY}'/'${container_name}:${OPENSTACK_VERSION}-${tag} || exit_code=1
      fi
      local duration_src=$(date +"%s")
      (( duration_src -= duration ))
      log "Docker build from source duration: $duration_src seconds" | append_log_file $logfile
    fi
  fi

  if [ $exit_code -eq 0 -a ${CONTRAIL_REGISTRY_PUSH} -eq 1 ]; then
    docker push ${CONTRAIL_REGISTRY}'/'${container_name}:${tag} 2>&1 | append_log_file $logfile
    exit_code=${PIPESTATUS[0]}
    # temporary workaround; to be removed when all other components switch to new tags
    docker push ${CONTRAIL_REGISTRY}'/'${container_name}:${OPENSTACK_VERSION}-${tag} 2>&1 | append_log_file $logfile
  fi
  duration=$(date +"%s")
  (( duration -= start_time ))
  if [ ${exit_code} -eq 0 ]; then
    if [[ "${CONTRAIL_KEEP_LOG_FILES,,}" != 'true' ]] ; then
      rm -f $logfile
    fi
    log "Building $container_name finished successfully, duration: $duration seconds" | append_log_file $logfile true
  else
    err "Building $container_name failed, duration: $duration seconds" 2>&1 | append_log_file $logfile true
    was_errors=1
  fi
  return $exit_code
}

function process_dir() {
  local dir=${1%/}
  local docker_file="$dir/Dockerfile"
  local res=0
  if [[ -f "$docker_file" ]] ; then
    process_container "$dir" "$docker_file" || res=1
    return $res
  fi
  for d in $(ls -d $dir/*/ 2>/dev/null); do
    if [[ $d != "./" && $d == */general-base* ]]; then
      process_dir $d || res=1
    fi
  done
  for d in $(ls -d $dir/*/ 2>/dev/null); do
    if [[ $d != "./" && $d == */base* ]]; then
      process_dir $d || res=1
    fi
  done
  for d in $(ls -d $dir/*/ 2>/dev/null); do
    if [[ $d != "./" && $d != *base* ]]; then
      process_dir $d || res=1
    fi
  done
  return $res
}

function update_file() {
  local file=$1
  local new_content=$2
  local content_encoded=${3:-'false'}
  local file_md5=${file}.md5
  if [[ -f "$file" && -f "$file_md5" ]] ; then
    log "$file and it's checksum "$file_md5" are exist, check them"
    local new_md5
    if [[ "$content_encoded" == 'true' ]] ; then
      new_md5=`echo "$new_content" | base64 --decode | md5sum | awk '{print($1)}'`
    else
      new_md5=`echo "$new_content" | md5sum | awk '{print($1)}'`
    fi
    local old_md5=`cat "$file_md5" | awk '{print($1)}'`
    if [[ "$old_md5" == "$new_md5" ]] ; then
      log "content of $file is not changed"
      return
    fi
  fi
  log "update $file and it's checksum $file_md5"
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
    update_file "k8s-manifests/$dfile" "$content"
    # this is special case - image derived directly from ubuntu image
    update_file "vrouter/kernel-build-init/$dfile" "$content"
  done
}

function process_list() {
  local list="$@"
  local i=''
  local jobs=''
  log "process list: $list"
  for i in $list ; do
    process_dir $i &
    jobs+=" $!"
  done
  local res=0
  for i in $jobs ; do
    wait $i || {
      res=1
      was_errors=1
    }
  done
  return $res
}

function process_all_parallel() {
  local full_list=$($my_dir/build.sh list | grep -v INFO)
  process_list general-base || return 1
  process_list base || return 1
  local list=$(echo "$full_list" | grep 'external\|\/base')
  process_list $list || return 1
  local list=$(echo "$full_list" | grep -v 'external\|base')
  process_list $list || return 1
}

if [[ $path == 'list' ]] ; then
  op='list'
  path="."
fi

if [ -z $path ] || [ $path = 'all' ]; then
  path="."
fi

log "starting build from $my_dir with relative path $path"
pushd $my_dir &>/dev/null

case $op in
  'build_parallel')
    log "prepare Contrail repo file in base image"
    update_repos "repo"
    if [[ "$path" == "." || "$path" == "all" ]] ; then
      process_all_parallel
    else
      process_dir $path
    fi
    ;;

  'build')
    log "prepare Contrail repo file in base image"
    update_repos "repo"
    process_dir $path
    ;;

  *)
    process_dir $path
    ;;
esac

popd &>/dev/null

if [ $was_errors -ne 0 ]; then
  log_files=$(ls -l $my_dir/*.log)
  err "Failed to build some containers, see log files:\n$log_files"
  exit 1
fi
