#!/bin/bash -e

source /common.sh
xflow_config_file="/etc/rsyslog.d/xflow.conf"
rsyslogd_pid_file="/var/run/rsyslogd.pid"
rm -f "${xflow_config_file}"
rm -f "${rsyslogd_pid_file}"

if [ -n "$XFLOW_NODE_IP" ] ; then
cat >> "${xflow_config_file}" << EOM
:msg, contains, "SessionData" @$XFLOW_NODE_IP:$RSYSLOGD_XFLOW_LISTEN_PORT
EOM
fi

exec "$@"
