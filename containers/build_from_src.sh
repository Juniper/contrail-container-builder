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
  cd $build_root
  while read line; do
    src_folder=$(echo $line | awk '{ print $1 }' | tr -d "[:space:]")
    dst_folder=$(echo $line | awk '{ print $2 }' | tr -d "[:space:]")    
    pushd $src_folder
    if [[ $dst_folder == '' ]]; then
     dst_folder='/'
    fi
    log "Launch Setup.py within ${src_folder} with root to ${dst_folder}..."
    time python setup.py install --root=${dst_folder}
    exitcode=${PIPESTATUS[0]}
    if [[ $exitcode -ne 0 ]]; then
      log "Setup.py within ${src_folder} finished with error"
      exit 1
    fi
    popd
  done < "${build_path}/.src"
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
