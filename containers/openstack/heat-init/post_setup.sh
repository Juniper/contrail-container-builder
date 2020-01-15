#!/bin/bash
lib_path="/opt/contrail/site-packages"
mkdir -p "$lib_path"
cp -rpf /usr/lib/python2.7/site-packages/contrail_heat* "$lib_path"
cp -rpf /usr/lib/python2.7/site-packages/vnc_api* "$lib_path"
cp -rpf /usr/lib/python2.7/site-packages/cfgm_common* "$lib_path"
rm -rf /usr/lib/python2.7/site-packages/contrail_heat*
rm -rf /usr/lib/python2.7/site-packages/vnc_api*
rm -rf /usr/lib/python2.7/site-packages/cfgm_common*
python2 -m pip install --no-compile --no-cache-dir --target="$lib_path" future six
