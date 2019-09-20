#!/bin/bash

sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf

# comma separated list of components to install
build_root=${1:-${CONTRAIL_SOURCE//\"/}}
components=${2:-${CONTRAIL_COMPONENTS//\"/}}

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

[ -z "$components" ] && components=$(ls .)
log "Components to setups $components"

function python_packages_requires() {
  local python_lib="/usr/lib/python2.7/site-packages"  
  local directory=`pwd`
  local matched_dependancies=0
  local number_of_dependancies=0
  local egg_info_folder=`ls -al ${directory} | awk '{print $9}'| grep egg-info`
  local requires_path="${directory}/${egg_info_folder}/requires.txt"
  local require_items=''
  [ -e $requires_path ] && require_items+=$(cat $requires_path)  
  require_items=$(echo -e "$require_items" | sed 's/[>=!,.].*/\n/g' )
  local list_libs=`ls -al $python_lib | awk '{print $9}'`
  local list_rpms=`rpm -qa`
  
  for item in $require_items; do
   log "The dep is $item"
   if [[ ${item,,} == *"contrail"* ]]; then
      log "Skip contaiil $item, it is already installed"      
      continue
   fi
   ((number_of_dependancies=number_of_dependancies+1))
   local match=0
   for lib in $list_libs; do
     if [[ ${lib,,} == *${item,,}* ]]; then
      log "It is a match in lib $lib and $item"
      ((matched_dependancies=matched_dependancies+1))
      ((match++))
      break
     fi
   done
   #Checking in rpms
   if [[ $match -eq 0 ]]; then
    for rpm in $list_rpms; do
      if [[ ${rpm,,} == *${item,,}* ]]; then
       log "It is a match in rpm $rpm and $item"    
       ((matched_dependancies=matched_dependancies+1))
       break       
      fi   
    done     
   fi
  done
  log "matched_dependancies is $matched_dependancies, number_of_dependancies is  $number_of_dependancies"
  if [[ $matched_dependancies != $number_of_dependancies ]]; then
   log "$matched_dependancies is not equel to $number_of_dependancies"
   return 1
  else 
   return 0
  fi
}


for i in ${components//,/ } ; do
  pushd $i
  python setup.py egg_info
  python_packages_requires
  exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
   log "Launching setup.py"
   time python setup.py install
  else
   log "It is not enough dependancies installed to launch setup.py and continue to build from source"
   exit 1
  fi
  popd
done

for i in /var/lib/contrail /var/log/contrail ; do
  mkdir -p $i
  setup_user $i
done

yum clean all -y
rm -rf /var/cache/yum
