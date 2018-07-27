#!/bin/bash

set -ex

# linux distro here always centos for now
src_path='/usr/lib/python2.7/site-packages'
src64_path='/usr/lib64/python2.7/site-packages'

mkdir -p /opt/plugin/site-packages
for module in contrail_heat vnc_api cfgm_common pycassa pysandesh gevent ; do
  if [[ -d ${src_path}/${module} ]]; then
    for item in `ls -d $src_path/${module}*` ; do
      cp -r ${item} /opt/plugin/site-packages/
    done
  else
    if [[ -d ${src64_path}/${module} ]]; then
      for item in `ls -d ${src64_path}/${module}*` ; do
        cp -r ${item} /opt/plugin/site-packages/
      done
    fi
  fi
done
