#!/bin/bash

source /common.sh

function get_server_json_list(){
  server_typ=$1_NODES
  srv_list=$(echo ${!server_typ} | sed 's/,/'\',\''/g')
  echo "['"$srv_list"']"
}

cat > /etc/contrail/config.global.js << EOM
/*
 * Copyright (c) 2014 Juniper Networks, Inc. All rights reserved.
 */

var config = {};

config.orchestration = {};
config.orchestration.Manager = "${orchestration_Manager:-none}";

config.serviceEndPointFromConfig = ${serviceEndPointFromConfig:-true};

config.regionsFromConfig = ${regionsFromConfig:-false};

config.endpoints = {};
config.endpoints.apiServiceType = "${endpoints_apiServiceType:-ApiServer}";
config.endpoints.opServiceType = "${endpoints_apiServiceType:-OpServer}";

config.regions = {};
config.regions.RegionOne = "${regions_RegionOne:-http://127.0.0.1:5000/v2.0}";

config.serviceEndPointTakePublicURL = ${serviceEndPointTakePublicURL:-true};

config.networkManager = {};
config.networkManager.ip = "${networkManager_ip:-127.0.0.1}";
config.networkManager.port = "${networkManager_port:-9696}";
config.networkManager.authProtocol = "${networkManager_authProtocol:-http}";
config.networkManager.apiVersion = ${networkManager_apiVersion:-[]};
config.networkManager.strictSSL = ${networkManager_strictSSL:-false};
config.networkManager.ca = "$networkManager_ca";

config.imageManager = {};
config.imageManager.ip = "${imageManager_ip:-127.0.0.1}";
config.imageManager.port = "${imageManager_port:-9292}";
config.imageManager.authProtocol = "${imageManager_authProtocol:-http}";
config.imageManager.apiVersion = ${imageManager_apiVersion:-['v1', 'v2']};
config.imageManager.strictSSL = ${imageManager_strictSSL:-false};
config.imageManager.ca = "$imageManager_ca";

config.computeManager = {};
config.computeManager.ip = "${computeManager_ip:-127.0.0.1}";
config.computeManager.port = "${computeManager_port:-8774}";
config.computeManager.authProtocol = "${computeManager_authProtocol:-http}";
config.computeManager.apiVersion = ${computeManager_apiVersion:-['v1.1', 'v2']};
config.computeManager.strictSSL = ${computeManager_strictSSL:-false};
config.computeManager.ca = "$computeManager_ca";

config.identityManager = {};
config.identityManager.ip = "${identityManager_ip:-127.0.0.1}";
config.identityManager.port = "${identityManager_port:-5000}";
config.identityManager.authProtocol = "${identityManager_authProtocol:-http}";
config.identityManager.apiVersion = ${identityManager_apiVersion:-['v2.0']};
config.identityManager.strictSSL = ${identityManager_strictSSL:-false};
config.identityManager.ca = "$identityManager_ca";

config.storageManager = {};
config.storageManager.ip = "${storageManager_ip:-127.0.0.1}";
config.storageManager.port = "${storageManager_port:-8776}";
config.storageManager.authProtocol = "${storageManager_authProtocol:-http}";
config.storageManager.apiVersion = ${storageManager_apiVersion:-['v1']};
config.storageManager.strictSSL = ${storageManager_strictSSL:-false};
config.storageManager.ca = "$storageManager_ca";

config.cnfg = {};
config.cnfg.server_ip = ${cnfg_server_ip:-`get_server_json_list CONFIG`};
config.cnfg.server_port = ${cnfg_server_port:-"'"$CONFIG_API_PORT"'"};
config.cnfg.authProtocol = "${cnfg_authProtocol:-http}";
config.cnfg.strictSSL = ${cnfg_strictSSL:-false};
config.cnfg.ca = ${cnfg_ca:-''};
config.cnfg.statusURL = ${cnfg_statusURL:-'"/global-system-configs"'};

config.analytics = {};
config.analytics.server_ip = ${analytics_server_ip:-`get_server_json_list ANALYTICS`};
config.analytics.server_port = ${analytics_server_port:-"'"$ANALYTICS_API_PORT"'"};
config.analytics.authProtocol = "${analytics_authProtocol:-http}";
config.analytics.strictSSL = ${analytics_strictSSL:-false};
config.analytics.ca = ${analytics_ca:-''};
config.analytics.statusURL = ${analytics_statusURL:-'"/analytics/uves/bgp-peers"'};

config.dns = {};
config.dns.server_ip = ${dns_server_ip:-`get_server_json_list CONFIG`};
config.dns.server_port = ${dns_server_port:-"'"$DNS_INTROSPECT_PORT"'"};
config.dns.statusURL = ${dns_statusURL:-'"/Snh_PageReq?x=AllEntries%20VdnsServersReq"'};

config.vcenter = {};
config.vcenter.server_ip = '127.0.0.1';         //vCenter IP
config.vcenter.server_port = '443';             //Port
config.vcenter.authProtocol = 'https';          //http or https
config.vcenter.datacenter = 'vcenter';          //datacenter name
config.vcenter.dvsswitch = 'vswitch';           //dvsswitch name
config.vcenter.strictSSL = false;               //Validate the certificate or ignore
config.vcenter.ca = '';                         //specify the certificate key file
config.vcenter.wsdl = '/usr/src/contrail/contrail-web-core/webroot/js/vim.wsdl';

config.introspect = {};
config.introspect.ssl = {};
config.introspect.ssl.enabled = false;
config.introspect.ssl.key = '';
config.introspect.ssl.cert = '';
config.introspect.ssl.ca = '';
config.introspect.ssl.strictSSL = false;

config.jobServer = {};
config.jobServer.server_ip = '127.0.0.1';
config.jobServer.server_port = '$WEBUI_JOB_SERVER_PORT';

config.files = {};
config.files.download_path = '/tmp';

config.cassandra = {};
config.cassandra.server_ips = ${cassandra_server_ips:-`get_server_json_list CONFIGDB`};
config.cassandra.server_port = ${cassandra_server_port:-"'"$CONFIGDB_CQL_PORT"'"};
config.cassandra.enable_edit = ${cassandra_enable_edi:-false};

config.kue = {};
config.kue.ui_port = '$KUE_UI_PORT'

config.webui_addresses = ['0.0.0.0'];

config.insecure_access = false;

config.http_port = '$WEBUI_HTTP_LISTEN_PORT';

config.https_port = '$WEBUI_HTTPS_LISTEN_PORT';

config.require_auth = false;

config.node_worker_count = 1;

config.maxActiveJobs = 10;

config.redisDBIndex = 3;

config.CONTRAIL_SERVICE_RETRY_TIME = 300000; //5 minutes

config.redis_server_port = '$REDIS_SERVER_PORT';
config.redis_server_ip = '$REDIS_SERVER_IP';
config.redis_dump_file = '/var/lib/redis/dump-webui.rdb';
config.redis_password = '$REDIS_SERVER_PASSWORD';

config.logo_file = '/usr/src/contrail/contrail-web-core/webroot/img/opencontrail-logo.png';

config.favicon_file = '/usr/src/contrail/contrail-web-core/webroot/img/opencontrail-favicon.ico';

config.featurePkg = {};
config.featurePkg.webController = {};
config.featurePkg.webController.path = '/usr/src/contrail/contrail-web-controller';
config.featurePkg.webController.enable = true;

config.qe = {};
config.qe.enable_stat_queries = false;

config.logs = {};
config.logs.level = '${WEBUI_LOG_LEVEL:-debug}';

config.getDomainProjectsFromApiServer = false;
config.network = {};
config.network.L2_enable = false;

config.getDomainsFromApiServer = false;
config.jsonSchemaPath = "/usr/src/contrail/contrail-web-core/src/serverroot/configJsonSchemas";
module.exports = config;
EOM

set_vnc_api_lib_ini

exec "$@"
