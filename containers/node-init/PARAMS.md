# contrail-node-init parameters

| parameters                                | default                                              |
| ----------------------------------------- | ---------------------------------------------------- |
| **Alarm generator**                       |                                                      |
| ALARMGEN_INTROSPECT_PORT                  | 5995                                                 |
| **Analytics**                             |                                                      |
| ANALYTICSDB_PORT                          | 9160                                                 |
| ANALYTICS_API_INTROSPECT_PORT             | 8090                                                 |
| ANALYTICS_API_PORT                        | 8081                                                 |
| ANALYTICS_NODEMGR_PORT                    | 8104                                                 |
| **BGP**                                   |                                                      |
| BGP_PORT                                  | 179                                                  |
| **Collector**                             |                                                      |
| COLLECTOR_INTROSPECT_PORT                 | 8089                                                 |
| COLLECTOR_IPFIX_PORT                      | 4739                                                 |
| COLLECTOR_PORT                            | 8086                                                 |
| COLLECTOR_PROTOBUF_PORT                   | 3333                                                 |
| COLLECTOR_SFLOW_PORT                      | 6343                                                 |
| COLLECTOR_STRUCTURED_SYSLOG_PORT          | 3514                                                 |
| COLLECTOR_SYSLOG_PORT                     | 514                                                  |
| SNMPCOLLECTOR_INTROSPECT_PORT             | 5920                                                 |
| **Config**                                |                                                      |
| CASSANDRA_CQL_PORT                        | 9042                                                 |
| CASSANDRA_JMX_LOCAL_PORT                  | 7200                                                 |
| CASSANDRA_PORT                            | 9160                                                 |
| CASSANDRA_SSL_STORAGE_PORT                | 7011                                                 |
| CASSANDRA_STORAGE_PORT                    | 7010                                                 |
| CONFIGDB_CQL_PORT                         | 9041                                                 |
| CONFIGDB_PORT                             | 9161                                                 |
| CONFIG_API_INTROSPECT_PORT                | 8084                                                 |
| CONFIG_API_PORT                           | 8082                                                 |
| CONFIG_DATABASE_NODEMGR_PORT              | 8112                                                 |
| CONFIG_DEVICE_MANAGER_INTROSPECT_PORT     | 8096                                                 |
| CONFIG_NODEMGR_PORT                       | 8100                                                 |
| CONFIG_SCHEMA_TRANSFORMER_INTROSPECT_PORT | 8087                                                 |
| CONFIG_SVC_MONITOR_INTROSPECT_PORT        | 8088                                                 |
| **Control**                               |                                                      |
| CONTROL_DNS_XMPP_PORT                     | 8093                                                 |
| CONTROL_INTROSPECT_PORT                   | 8083                                                 |
| CONTROL_NODEMGR_PORT                      | 8101                                                 |
| **Controller**                            |                                                      |
| CONTROLLER_DATABASE_NODEMGR_PORT          | 8103                                                 |
| **DNS**                                   |                                                      |
| DNS_INTROSPECT_PORT                       | 8092                                                 |
| DNS_SERVER_PORT                           | 53                                                   |
| **IP tables**                             |                                                      |
| CONFIGURE_IPTABLES                        | false                                                |
| IPTABLES_CHAIN                            | INPUT                                                |
| IPTABLES_TABLE                            | filter                                               |
| **Firewalld**                             |                                                      |
| CONFIGURE_FIREWALLD                       | false                                                |
| FIREWALL_ZONE                             | public                                               |
| **Kafka**                                 |                                                      |
| KAFKA_PORT                                | 9092                                                 |
| **Kubernetes**                            |                                                      |
| K8S_CA_FILE                               | /var/run/secrets/kubernetes.io/serviceaccount/ca.crt |
| K8S_TOKEN_FILE                            | /var/run/secrets/kubernetes.io/serviceaccount/token  |
| KUBEMANAGER_INTROSPECT_PORT               | 8108                                                 |
| KUBERNETES_API_PORT                       | 8080                                                 |
| KUBERNETES_API_SERVER                     |                                                      |
| KUBERNETES_PORT_443_TCP_PORT              |                                                      |
| KUBERNETES_SERVICE_HOST                   |                                                      |
| **Node initialization**                   |                                                      |
| CONTRAIL_STATUS_IMAGE                     |                                                      |
| CONTRAIL_STATUS_CONTAINER_NAME            | contrail-status                                      |
| INSTALL_PUPPET                            | false                                                |
| INSTALL_PUPPET_DIR                        | /tmp                                                 |
| **Redis**                                 |                                                      |
| REDIS_SERVER_PORT                         | 6379                                                 |
| **RabbitMQ**                              |                                                      |
| RABBITMQ_DIST_PORT                        | $RABBITMQ_NODE_PORT + 20000                          |
| RABBITMQ_EPMD_PORT                        | 4369                                                 |
| RABBITMQ_NODE_PORT                        | 5673                                                 |
| **Server SSL**                            |                                                      |
| CA_PRIVATE_KEY_BITS                       | 4096                                                 |
| FORCE_GENERATE_CERT                       | false                                                |
| PRIVATE_KEY_BITS                          | 2048                                                 |
| SELFSIGNED_CERTS_WITH_IPS                 | True                                                 |
| SERVER_CA_CERTFILE                        | /etc/contrail/ssl/certs/ca-cert.pem                  |
| SERVER_CA_KEYFILE                         | /tmp/contrail_ssl_gen/certs/ca.key.pem               |
| SERVER_CERTFILE                           | /etc/contrail/ssl/certs/server.pem                   |
| SERVER_KEYFILE                            | /etc/contrail/ssl/private/server-privkey.pem         |
| **Topology**                              |                                                      |
| TOPOLOGY_INTROSPECT_PORT                  | 5921                                                 |
| **Query engine**                          |                                                      |
| QUERYENGINE_INTROSPECT_PORT               | 8091                                                 |
| **vRouter**                               |                                                      |
| VROUTER_AGENT_INTROSPECT_PORT             | 8085                                                 |
| VROUTER_AGENT_METADATA_PROXY_PORT         | 8097                                                 |
| VROUTER_AGENT_NODEMGR_PORT                | 8102                                                 |
| VROUTER_PORT                              | 9091                                                 |
| **WebUI**                                 |                                                      |
| WEBUI_HTTPS_LISTEN_PORT                   | 8143                                                 |
| WEBUI_HTTP_LISTEN_PORT                    | 8180                                                 |
| **XMPP**                                  |                                                      |
| XMPP_SERVER_PORT                          | 5269                                                 |
| **Zookeeper**                             |                                                      |
| ZOOKEEPER_PORT                            | 2181                                                 |
| ZOOKEEPER_PORTS                           | 2888:3888                                            |
