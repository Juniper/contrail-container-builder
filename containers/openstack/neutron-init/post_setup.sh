#!/bin/bash
lib_path="/opt/contrail/site-packages"
mkdir -p $lib_path
cp -rpf /usr/lib/python2.7/site-packages/neutron_plugin_contrail* "$lib_path"
cp -rpf /usr/lib/python2.7/site-packages/vnc_api* "$lib_path"
cp -rpf /usr/lib/python2.7/site-packages/cfgm_common* "$lib_path"
rm -rf /usr/lib/python2.7/site-packages/neutron_plugin_contrail*
rm -rf /usr/lib/python2.7/site-packages/vnc_api*
rm -rf /usr/lib/python2.7/site-packages/cfgm_common*
python2 -m pip install --no-compile --no-cache-dir --target="$lib_path" future six
/_prepare_packages.sh && rm -f /_prepare_packages.sh
