#!/bin/bash

[ -e "/contrail-setup-common.sh" ] && source /contrail-setup-common.sh

build_root=${CONTRAIL_SOURCE//\"/}
build_path=${build_root}/${CONTAINER_SOURCE_DATA_PATH//\"/}

setup_prefix="/usr"
function log() {
  echo "INFO: SETUP.SH: $@"
}

function setup_user() {
  local path="$1"
  local mode=${2:-"0744"}
  [[ -n "$CONTRAIL_UID" && \
     -n "$CONTRAIL_GID" && \
     "$(id -u)" = '0' ]] && chown -R $CONTRAIL_UID:$CONTRAIL_GID $path
  [[ -n $"mode" ]] && chmod -R $mode $path
}

function is_elf() {
  [[ 'ELF' == "$(dd if=$1 count=3 bs=1 skip=1 2>/dev/null)" ]]
}

function strip_file() {
  local file=$1
  is_elf $file &&  strip --strip-unneeded -p $file
}

function strip_folder() {
  local folder=$1
  find $folder -type f | while read file ; do
    strip_file $file
  done
}

CONTRAIL_DEPS=''
[ -e ${build_path}/.deps ] && CONTRAIL_DEPS+=$(cat ${build_path}/.deps)
[ -e ${build_path}/.deps.$LINUX_DISTR ] && CONTRAIL_DEPS+="\n$(cat ${build_path}/.deps.$LINUX_DISTR)"
CONTRAIL_DEPS=$(echo -e "$CONTRAIL_DEPS" | sed '/^$/d' | sort | uniq | tr '\n' ',')
CONTRAIL_DEPS=${CONTRAIL_DEPS%%//,}
CONTRAIL_DEPS=${CONTRAIL_DEPS##//,}
CONTRAIL_DEPS=$(echo ${CONTRAIL_DEPS//,/ } | tr -d '"' | sort | uniq)
log "Contrail deps is ${CONTRAIL_DEPS}"
if [[ -n "$CONTRAIL_DEPS" ]] ; then
  time yum update all -y
  time yum install -y $CONTRAIL_DEPS
  exitcode=${PIPESTATUS[0]}
  log "YUM exitcode is ${exitcode}"
  if [[ $exitcode -ne 0 ]]; then
   log "YUM is finished with error"
   exit 1
  fi
else
   log "There is no dependecies to install. Continue."
fi

if [[ -z "$build_root" ]] ; then
  log "No source code provided, exiting with error"
  exit 1
fi
log "Build root is ${build_root}"

if [[ -f ${build_path}/.src ]]; then
  cd $build_root
  while read line; do
    src_folder=$(echo $line | awk '{ print $1 }' | tr -d "[:space:]")
    dst_folder=$(echo $line | awk '{ print $2 }' | tr -d "[:space:]")
    pushd $src_folder
    [[ -z ${dst_folder} ]] && dst_folder='/'
    log "Launch Setup.py within ${src_folder} with root to ${dst_folder} and prefix ${setup_prefix} ..."
    time python setup.py install --root=${dst_folder} --prefix=${setup_prefix} --no-compile
    exitcode=${PIPESTATUS[0]}
    if [[ $exitcode -ne 0 ]]; then
      log "Setup.py within ${src_folder} finished with error"
      exit 1
    fi
    popd
  done < "${build_path}/.src"
fi

log "Copying folders call.."
if [[ -f ${build_path}/.copy_folders ]]; then
  cd $build_root
  while read line; do
    if [[ -z ${line} ]]; then
      log "Empty line, End of file."
      break
    fi
    src_folder=$(echo $line | awk '{ print $1 }' | tr -d "[:space:]")
    dst_folder=$(echo $line | awk '{ print $2 }' | tr -d "[:space:]")
    mkdir -p $dst_folder
    log "Copying files from  $src_folder to $dst_folder"
    cp -R --dereference $src_folder $dst_folder && setup_user $dst_folder
    exitcode=${PIPESTATUS[0]}
    if [[ $exitcode -ne 0 ]]; then
      log "Copying of source folder ${src_folder} to ${dst_folder} finished with error"
      exit 1
    fi
    strip_folder $dst_file
  done < "${build_path}/.copy_folders"
fi

log "Copying files call.."
if [[ -f ${build_path}/.copy_files ]]; then
  cd $build_root
  while read line; do
    if [[ -z ${line} ]]; then
      log "Empty line, End of file."
      break
    fi
    src_file=$(echo $line | awk '{ print $1 }' | tr -d "[:space:]")
    dst_file=$(echo $line | awk '{ print $2 }' | tr -d "[:space:]")
    dst_folder="${dst_file%/*}"
    mkdir -p $dst_folder
    setup_user $dst_folder 0755
    log "Copying files from  $src_file to $dst_file"
    cp -fp $src_file $dst_file && setup_user $dst_file 0755
    exitcode=${PIPESTATUS[0]}
    if [[ $exitcode -ne 0 ]]; then
      log "Copying of source file ${src_file} to ${dst_file} finished with error"
      exit 1
    fi
    strip_file $dst_file
  done < "${build_path}/.copy_files"
fi

for i in /var/lib/contrail /var/log/contrail ; do
  mkdir -p $i
  setup_user $i
done

if [ -x "$(command -v yum)" ] ; then
  yum clean all -y
  rm -rf /var/cache/yum
fi

ldconfig
