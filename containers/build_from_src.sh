#!/bin/bash
build_root=${CONTRAIL_SOURCE//\"/}
build_path=${build_root}/${CONTAINER_SOURCE_DATA_PATH//\"/}

[ -e "/pre_setup.sh" ] && source /pre_setup.sh
[ -e "/contrail-setup-common.sh" ] && source /contrail-setup-common.sh

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

function trim() {
   read -r line
   echo "$line"
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
  find $folder  -type f \( -iname "*" ! -iname "*.js" ! -iname "*.py*" ! -iname "*.md" \) | while read file ; do
    strip_file $file
  done
}

function pip_installation() {
  local python_exec=$1
  if [ -x "$(command -v ${python_exec} )" ] ; then
    $python_exec -m pip --version
    local exitcode=${PIPESTATUS[0]}
    if [ $exitcode -ne 0 ] ; then
      log "Start downloading and installing pip for ${python_exec}..."
      curl "https://bootstrap.pypa.io/get-pip.py" | "${python_exec}"
      local exitcode=${PIPESTATUS[0]}
      log "Pip installation exitcode is ${exitcode}"
      if [[ $exitcode -ne 0 ]] ; then
        log "Pip installation is finished with error"
        exit 1
      fi
    fi
  fi
}

function pip_libs_install() {
  local python_exec=$1
  local file_with_libs=$2
  local opt="--no-compile --no-cache-dir"
  local libs=""
  while read lib; do    
    libs="${libs} ${lib}"
  done < "${file_with_libs}"  
  if [[ $( echo $libs | trim ) == "" ]] ; then
    log "The list of libs is empty. Continue... "
  else
    libs="$(echo "${libs}" | sed -e 's/[[:space:]]*$//')"
    log "We are going to install the following ${libs} "
    log "The command for pip run is: ${python_exec} -m pip install ${opt} ${libs}"
    ${python_exec} -m pip install ${opt} ${libs}
    exitcode=${PIPESTATUS[0]}
    log "Pip libs installation exitcode is ${exitcode}"
    if [[ $exitcode -ne 0 ]]; then
      log "Pip libs installation is finished with error"
      exit 1
    fi
  fi
}

CONTRAIL_DEPS=''
[ -e ${build_path}/.deps ] && CONTRAIL_DEPS+=$(cat ${build_path}/.deps)
[ -e ${build_path}/.deps.$LINUX_DISTR ] && CONTRAIL_DEPS+="\n$(cat ${build_path}/.deps.$LINUX_DISTR)"
CONTRAIL_DEPS=$(echo -e "$CONTRAIL_DEPS" | sed '/^$/d' | sort | uniq | tr '\n' ',')
CONTRAIL_DEPS=${CONTRAIL_DEPS%%//,}
CONTRAIL_DEPS=${CONTRAIL_DEPS##//,}
CONTRAIL_DEPS=$(echo ${CONTRAIL_DEPS//,/ } | tr -d '"' | sort | uniq)
log "Contrail deps is ${CONTRAIL_DEPS}"
if [[ -e  ${build_path}/.docs ]] ; then
  sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf
fi
if [[ -n "$CONTRAIL_DEPS" ]] ; then
  time yum install -y $CONTRAIL_DEPS
  exitcode=${PIPESTATUS[0]}
  log "YUM exitcode is ${exitcode}"
  if [[ $exitcode -ne 0 ]]; then
   log "YUM is finished with error"
   exit 1
  fi
else
   log "There is no dependencies to install. Continue."
fi

if [[ -z "$build_root" ]] ; then
  log "No source code provided, exiting with error"
  exit 1
fi
log "Build root is ${build_root}"

[ -e "${build_path}/.pip2" ] && pip_installation "python2"
[ -e "${build_path}/.pip3" ] && pip_installation "python3"

if [[ -f ${build_path}/.src ]]; then
  cd $build_root
  while read line; do
    [ -z "$line" ] && continue
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
    [ -z "$line" ] && continue
    src_folder=$(echo $line | awk '{ print $1 }' | tr -d "[:space:]")
    dst_folder=$(echo $line | awk '{ print $2 }' | tr -d "[:space:]")
    mkdir -p $dst_folder
    log "Copying files from  $src_folder to $dst_folder"
    cp -p -R --dereference $src_folder $dst_folder
    exitcode=${PIPESTATUS[0]}
    if [[ $exitcode -ne 0 ]]; then
      log "Copying of source folder ${src_folder} to ${dst_folder} finished with error"
      exit 1
    fi
    strip_folder ${dst_folder}
  done < "${build_path}/.copy_folders"
fi

log "Copying files call.."
if [[ -f ${build_path}/.copy_files ]]; then
  cd $build_root
  while read line; do
    [ -z "$line" ] && continue
    src_file=$(echo $line | awk '{ print $1 }' | tr -d "[:space:]")
    dst_file=$(echo $line | awk '{ print $2 }' | tr -d "[:space:]")
    dst_folder="${dst_file%/*}"
    mkdir -p $dst_folder
    log "Copying files from  $src_file to $dst_file"
    cp -fp $src_file $dst_file
    exitcode=${PIPESTATUS[0]}
    if [[ $exitcode -ne 0 ]]; then
      log "Copying of source file ${src_file} to ${dst_file} finished with error"
      exit 1
    fi
    strip_file $dst_file
  done < "${build_path}/.copy_files"
fi

log "Let's install packages from pip execution..."
if [[ -x "$(command -v python2)" && -f ${build_path}/.pip2 ]] ; then
  pip_libs_install "python2" "${build_path}/.pip2"
fi

if [[ -x "$(command -v python3)" && -f ${build_path}/.pip3 ]] ; then
  pip_libs_install "python3" "${build_path}/.pip3"
fi

[ -e "/post_setup.sh" ] && source /post_setup.sh

if [[ ! -d /var/lib/contrail && ! -d /var/log/contrail ]] ; then
  for folder in /var/lib/contrail /var/log/contrail ; do
    mkdir -p $folder
    setup_user $folder
  done
fi

##
##Cleanup section
##

if [ -x "$(command -v yum)" ] ; then
  log "Start cleaning yum cache"
  yum clean all -y
  rm -rf /var/cache/yum
fi
if [[ -e  ${build_path}/.docs ]] ; then
  rm -rf /usr/share/doc/*
fi
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*
find / -type f \( -name "*.pyo" -o -name "*.pyc" -o -name "*.pyd" \) \
  -exec sh -c 'rm -rf "$0"' {} \;
rm -rf /pre_setup.sh /post_setup.sh

ldconfig
