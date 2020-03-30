#!/bin/bash

source /common.sh

DNS_NAMED_CONFIG_FILE=${DNS_NAMED_CONFIG_FILE:-'contrail-named.conf'}
DNS_NAMED_CONFIG_DIRECTORY=${DNS_NAMED_CONFIG_DIRECTORY:-'/etc/contrail/dns'}

mkdir -p ${DNS_NAMED_CONFIG_DIRECTORY}
cat > ${DNS_NAMED_CONFIG_DIRECTORY}/${DNS_NAMED_CONFIG_FILE} << EOM
options {
    directory "${DNS_NAMED_CONFIG_DIRECTORY}";
    managed-keys-directory "${DNS_NAMED_CONFIG_DIRECTORY}";
    empty-zones-enable no;
    pid-file "${DNS_NAMED_CONFIG_DIRECTORY}/contrail-named.pid";
    session-keyfile "${DNS_NAMED_CONFIG_DIRECTORY}/session.key";
    listen-on port 53 { any; };
    allow-query { any; };
    allow-recursion { any; };
    allow-query-cache { any; };
    max-cache-size 32M;
};

key "rndc-key" {
    algorithm hmac-md5;
    secret "$RNDC_KEY";
};

controls {
    inet 127.0.0.1 port 8094
    allow { 127.0.0.1; }  keys { "rndc-key"; };
};

logging {
    channel debug_log {
        file "${CONTAINER_LOG_DIR}/contrail-named.log" versions 3 size 5m;
        severity debug;
        print-time yes;
        print-severity yes;
        print-category yes;
    };
    category default {
        debug_log;
    };
    category queries {
        debug_log;
    };
};
EOM

chown -R contrail:contrail ${DNS_NAMED_CONFIG_DIRECTORY}
touch ${CONTAINER_LOG_DIR}/contrail-named.log
chown contrail:contrail ${CONTAINER_LOG_DIR}/contrail-named.log
chown contrail:contrail ${CONTAINER_LOG_DIR}

exec "$@"
