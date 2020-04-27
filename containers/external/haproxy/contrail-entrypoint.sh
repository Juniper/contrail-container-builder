#!/bin/bash -e

HAPROXY_FILE=/etc/haproxy/haproxy.cfg
cat > $HAPROXY_FILE << EOM
global
        tune.maxrewrite 1024
        tune.bufsize 16384
        maxconn 10000
        spread-checks 4
        log /dev/log    local0
        log /dev/log    local1 notice
        stats timeout 30s
        daemon
        user haproxy
        group haproxy

        # Default SSL material locations
        ca-base /etc/contrail/ssl/certs
        crt-base /etc/contrail/ssl/private

        # Default ciphers to use on SSL-enabled listening sockets.
        # For more information, see ciphers(1SSL).
        ssl-default-bind-ciphers kEECDH+aRSA+AES:kRSA+AES:+AES256:RC4-SHA:!kEDH:!LOW:!EXP:!MD5:!aNULL:!eNULL

defaults
        log     global
        mode    http
        option                  tcplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000

EOM

IFS=',' read -ra ip_list <<< "$IP_LIST"
IFS=',' read -ra port_list <<< "$PORT_LIST"

len=${#ip_list[*]}
echo $len
i=0
labl_idx=1
port_idx=0
while [ $i -lt $len ];
do
    active_ip=${ip_list[$i]}
    active_port=${port_list[$port_idx]}
    i=$[$i+1]
    bkup_ip=${ip_list[$i]}
    bkup_port=${port_list[$port_idx]}
    i=$[$i+1]
    printf "listen contrail-tor-agent-%s\n" $labl_idx >> $HAPROXY_FILE
    printf "       option tcpka\n" >> $HAPROXY_FILE
    printf "       mode tcp\n" >> $HAPROXY_FILE
    printf "       bind :%s\n" $active_port >> $HAPROXY_FILE
    printf "       server %s %s:%s check inter 2000\n" $active_ip $active_ip $active_port >> $HAPROXY_FILE
    printf "       server %s %s:%s check inter 2000\n\n" $bkup_ip $bkup_ip $bkup_port >> $HAPROXY_FILE
    labl_idx=$[$labl_idx+1]
    port_idx=$[$port_idx+1]
done

exec /docker-entrypoint.sh "$@"
