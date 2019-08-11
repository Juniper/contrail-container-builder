#!/bin/bash -e

source /common.sh
xflow_config_file="/etc/rsyslog.d/xflow.conf"
rm -f "${xflow_config_file}"
if [ ! -z $XFLOW_NODE_IP ] ; then
cat >> "${xflow_config_file}" << EOM
*.* @$XFLOW_NODE_IP:$RSYSLOGD_XFLOW_LISTEN_PORT
EOM
fi

pidfile="/var/run/rsyslogd.pid"
rm -f "${pidfile}"
exec rsyslogd -n -f /etc/rsyslog.conf -i "${pidfile}"
