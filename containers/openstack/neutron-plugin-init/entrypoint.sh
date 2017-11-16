#!/bin/bash

PATH_PLUGIN=${PATH_PLUGIN:-"/tmp/neutron_plugin_contrail"}
PATH_PLUGIN_EGGINFO=${PATH_PLUGIN_EGGINFO:-"/tmp/neutron_plugin_contrail-0.1dev-py2.7.egg-info"}

cp -r /usr/lib/python2.7/neutron_plugin_contrail/* $PATH_PLUGIN
cp -r /usr/lib/python2.7/neutron_plugin_contrail-0.1dev-py2.7.egg-info/* $PATH_PLUGIN_EGGINFO
