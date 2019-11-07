#!/bin/bash

sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf
[ -e "/contrail-setup-common.sh" ] && source /contrail-setup-common.sh

build_path="/build_src"

function log() {
  echo "INFO: SETUP.SH: $@"
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

build_root=${CONTRAIL_SOURCE//\"/}
if [[ -z "$build_root" ]] ; then
  log "No source code provided, exiting with error"
  exit 1
fi
log "Build root is ${build_root}"

if [[ -f ${build_path}/.src ]]; then
 CONTRAIL_COMPONENTS=$(cat "${build_path}/.src" | sed '/^$/d' | tr '\n' ',')
 components=${CONTRAIL_COMPONENTS//\"/}
 log "Components is ${components}"
 cd $build_root
 for src_folder in ${components//,/ } ; do
  pushd $src_folder
  time python setup.py install --root=/ --prefix=/usr
  exitcode=${PIPESTATUS[0]}
  if [[ $exitcode -ne 0 ]]; then
   log "Setup.py within ${src_folder} finished with error"
   exit 1
  fi
  popd
 done
fi

if [[ -f ${build_path}/.copy_folders ]]; then
  cd $build_root
  while read line; do
    src_folder=$(echo $line | awk '{ print $1 }' | tr -d "[:space:]")
    dst_folder=$(echo $line | awk '{ print $2 }' | tr -d "[:space:]")
    [ ! -d "${dst_folder}" ] && mkdir -p $dst_folder
    cp -v -rf $src_folder $dst_folder && chmod -R 775 $dst_folder
    exitcode=${PIPESTATUS[0]}
    if [[ $exitcode -ne 0 ]]; then
      log "Copying of source folder ${src_folder} to ${dst_folder} finished with error"
      exit 1
    fi
  done < "${build_path}/.copy_folders"
fi

if [[ -f ${build_path}/.copy_files ]]; then
  cd $build_root
  while read line; do
    src_file=$(echo $line | awk '{ print $1 }' | tr -d "[:space:]")
    dst_file=$(echo $line | awk '{ print $2 }' | tr -d "[:space:]")    
    cp -v -f $src_file $dst_file && chmod 775 $dst_file
    exitcode=${PIPESTATUS[0]}
    if [[ $exitcode -ne 0 ]]; then
      log "Copying of source file ${src_file} to ${dst_file} finished with error"
      exit 1
    fi
  done < "${build_path}/.copy_files"
fi

function setup_user() {
  local path="$1"
  local mode=${2:-"0744"}
  [[ -n "$CONTRAIL_UID" && \
     -n "$CONTRAIL_GID" && \
     "$(id -u)" = '0' ]] && chown -R $CONTRAIL_UID:$CONTRAIL_GID $path
  [[ -n $"mode" ]] && chmod -R $mode $path
}

for i in /var/lib/contrail /var/log/contrail ; do
  mkdir -p $i
  setup_user $i
done

yum clean all -y
rm -rf /var/cache/yum
