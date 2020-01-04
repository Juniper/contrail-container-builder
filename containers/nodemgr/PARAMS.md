# contrail-nodemgr parameters

| parameters                        | default                                        |
| --------------------------------- | ---------------------------------------------- |
| **Analytics**                     |                                                |
| ANALYTICSDB_NODES                 | $ANALYTICS_NODES                               |
| ANALYTICS_ALARM_NODES             | $ANALYTICSDB_NODES                             |
| ANALYTICS_NODES                   | $CONTROLLER_NODES                              |
| ANALYTICS_SNMP_NODES              | $ANALYTICS_NODES                               |
| **Authentication**                |                                                |
| AUTH_MODE                         | noauth                                         |
| AUTH_PARAMS                       | ''                                             |
| **BGP**                           |                                                |
| BGP_ASN                           | 64512                                          |
| BGP_AUTO_MESH                     | true                                           |
| BGP_PORT                          | 179                                            |
| ENABLE_4BYTE_AS                   | false                                          |
| **Cloud orchestration**           |                                                |
| CLOUD_ORCHESTRATOR                | none                                           |
| **Collector**                     |                                                |
| COLLECTOR_SERVERS                 | $ANALYTICS_NODES with $COLLECTOR_PORT          |
| STATS_COLLECTOR_DESTINATION_PATH  |                                                |
| *COLLECTOR_PORT*                  | 8086                                           |
| **Config**                        |                                                |
| CASSANDRA_CQL_PORT                | 9042                                           |
| CASSANDRA_JMX_LOCAL_PORT          | 7200                                           |
| CASSANDRA_SSL_ENABLE              | false                                          |
| CONFIGDB_NODES                    | $CONFIG_NODES                                  |
| CONFIG_API_PORT                   | 8082                                           |
| CONFIG_API_SERVER_CA_CERTFILE     | $SERVER_CA_CERTFILE                            |
| CONFIG_API_SSL_ENABLE             | $SSL_ENABLE                                    |
| *CONFIG_NODES*                    | $CONTROLLER_NODES                              |
| **Control**                       |                                                |
| CONTROL_NODES                     | $CONFIG_NODES                                  |
| **Controller**                    |                                                |
| *CONTROLLER_NODES*                | IP address of the NIC performs default routing |
| **Host**                          |                                                |
| DIST_SNAT_PROTO_PORT_LIST         | ""                                             |
| ENCAP_PRIORITY                    | MPLSoUDP,MPLSoGRE,VXLAN                        |
| FLOW_EXPORT_RATE                  | 0                                              |
| **Introspect**                    |                                                |
| INTROSPECT_LISTEN_ALL             | True                                           |
| INTROSPECT_SSL_ENABLE             | $SSL_ENABLE                                    |
| **Keystone authentication**       |                                                |
| KEYSTONE_AUTH_ADMIN_PORT          | 35357                                          |
| KEYSTONE_AUTH_CA_CERTFILE         |                                                |
| KEYSTONE_AUTH_CERTFILE            |                                                |
| KEYSTONE_AUTH_HOST                | 127.0.0.1                                      |
| KEYSTONE_AUTH_INSECURE            | $SSL_INSECURE                                  |
| KEYSTONE_AUTH_KEYFILE             |                                                |
| KEYSTONE_AUTH_PROJECT_DOMAIN_NAME | Default                                        |
| KEYSTONE_AUTH_PROTO               | http                                           |
| KEYSTONE_AUTH_URL_TOKENS          | /v3/auth/tokens                                |
| **Logging**                       |                                                |
| LOG_DIR                           | /var/log/contrail                              |
| LOG_LEVEL                         | SYS_NOTICE                                     |
| LOG_LOCAL                         | 1                                              |
| **Node manager**                  |                                                |
| <NODE_TYPE>_NODES                 |                                                |
| IPFABRIC_SERVICE_HOST             |                                                |
| IPFABRIC_SERVICE_PORT             | 8775                                           |
| LINKLOCAL_SERVICE_IP              | 169.254.169.254                                |
| LINKLOCAL_SERVICE_NAME            | metadata                                       |
| LINKLOCAL_SERVICE_PORT            | 80                                             |
| NODEMGR_TYPE                      | $NODE_TYPE                                     |
| NODE_TYPE                         | name of the component                          |
| **Sandesh**                       |                                                |
| SANDESH_CA_CERTFILE               | $SERVER_CA_CERTFILE                            |
| SANDESH_CERTFILE                  | $SERVER_CERTFILE                               |
| SANDESH_KEYFILE                   | $SERVER_KEYFILE                                |
| SANDESH_SSL_ENABLE                | $SSL_ENABLE                                    |
| **Server SSL**                    |                                                |
| SSL_ENABLE                        | False                                          |
| *SERVER_CA_CERTFILE*              | /etc/contrail/ssl/certs/ca-cert.pem            |
| *SSL_INSECURE*                    | True                                           |
| **vRouter**                       |                                                |
| EXTERNAL_ROUTERS                  | ""                                             |
| MAINTENANCE_MODE                  |                                                |
| PROVISION_DELAY                   |                                                |
| PROVISION_RETRIES                 |                                                |
| SUBCLUSTER                        | ""                                             |
| VROUTER_GATEWAY                   |                                                |
| VROUTER_HOSTNAME                  |                                                |
| **XMPP**                          |                                                |
| XMPP_SSL_ENABLE                   | $SSL_ENABLE                                    |
