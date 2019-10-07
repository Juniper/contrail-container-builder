#!/bin/bash

sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf

build_path="/build_src"

if [[ -f ${build_path}/.src ]]; then
 src_items=$(cat "${build_path}/.src" | sed '/^$/d' | tr '\n' ',')
 CONTRAIL_COMPONENTS=$src_items
fi
build_root=${1:-${CONTRAIL_SOURCE//\"/}}

components=${2:-${CONTRAIL_COMPONENTS//\"/}}

[ -e "/contrail-setup-common.sh" ] && source /contrail-setup-common.sh

function log() {
  echo "INFO: CONFIG API: $@"
}

function setup_user() {
  local path="$1"
  local mode=${2:-"0744"}
  [[  -n "$CONTRAIL_UID" && \
      -n "$CONTRAIL_GID" &&  \
      "$(id -u)" = '0' ]] && chown -R $CONTRAIL_UID:$CONTRAIL_GID $path
  [[ -n $"mode" ]] && chmod -R $mode $path
}

CONTRAIL_DEPS=''
[ -e ${build_path}/.deps ] && CONTRAIL_DEPS+=$(cat ${build_path}/.deps)
[ -e ${build_path}/.deps.$LINUX_DISTR ] && CONTRAIL_DEPS+="\n$(cat ${build_path}/.deps.$LINUX_DISTR)"
CONTRAIL_DEPS=$(echo -e "$CONTRAIL_DEPS" | sed '/^$/d' | sort | uniq | tr '\n' ',')
CONTRAIL_DEPS=${CONTRAIL_DEPS%%//,}
CONTRAIL_DEPS=${CONTRAIL_DEPS##//,}
CONTRAIL_DEPS=$(echo ${CONTRAIL_DEPS//,/ } | tr -d '"' | sort | uniq)
if [[ -n "$CONTRAIL_DEPS" ]] ; then
  time yum update all -y
  time yum install -y $CONTRAIL_DEPS
fi


if [[ -z "$build_root" ]] ; then
  log "No source code provided, nothing to do"
  exit 0
fi

log "Build root path $build_root"

cd $build_root

for i in ${components//,/ } ; do
  pushd $i
  time python setup.py install
  popd
done

for i in /var/lib/contrail /var/log/contrail ; do
  mkdir -p $i
  setup_user $i
done

yum clean all -y
rm -rf /var/cache/yum
