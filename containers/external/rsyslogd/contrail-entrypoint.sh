#!/bin/bash -e

source /common.sh
xflow_config_file="/etc/contrail/rsyslog.d/xflow.conf"
rm -f "${xflow_config_file}"
if [ ! -z $XFLOW_NODES ] ; then
cat >> "${xflow_config_file}" << EOM
*.* @$XFLOW_NODES:$RSYSLOGD_XFLOW_PORT
EOM
fi

pidfile="/var/run/rsyslogd.pid"
rm -f "${pidfile}"
exec rsyslogd -n -f /etc/contrail/rsyslog.conf -i "${pidfile}"
