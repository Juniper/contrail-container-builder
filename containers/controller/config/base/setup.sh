#!/bin/bash -ex

# comma separated list of components to install
components=${1:-${CONTRAIL_SOURCE//\"/}}
contrail_source=${2:-${CONTRAIL_SOURCE_COPY//\"/}}

build_root=${3:-${CONTRAIL_BUILD_ROOT:-'/root/conrail'}}

[ -e "/contrail-setup-common.sh" ] && source /contrail-setup-common.sh


###########################
# move to common functions
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
###########################

if [[ -z "$contrail_source" ]] ; then
  log "No source code provided, nothing to do: contrail_source=$contrail_source"
  exit 0
fi

contrail_source="/$contrail_source"
log "Source code path $contrail_source"

mkdir -p $build_root
cd $build_root
tar -xf $contrail_source

[ -z "$components" ] && components=$(ls .)
log "Components to setups $components"

for i in ${components//,/ } ; do
  pushd $i
  time python setup.py install
  popd
done

fabricansible="/opt/contrail/fabric_ansible_playbooks"
if [ -e $fabricansible ] ; then
  setup_user $fabricansible
  mv ${fabricansible}/fabric_ansible_playbooks-0.1dev/* ${fabricansible}/
  rmdir  ${fabricansible}/fabric_ansible_playbooks-0.1dev
  mkdir -p /etc/ansible
  cp ${fabricansible}/ansible.cfg /etc/ansible/ansible.cfg
fi
