# contrail-analytics-topology parameters

| parameter                         | default                                        |
| --------------------------------- | ---------------------------------------------- |
| **Analytics**                     |                                                |
| ANALYTICS_NODES                   | $CONTROLLER_NODES                              |
| ANALYTICS_SERVERS                 | $ANALYTICS_NODES with $ANALYTICS_API_PORT      |
| TOPOLOGY_INTROSPECT_LISTEN_PORT   | $TOPOLOGY_INTROSPECT_PORT                      |
| TOPOLOGY_INTROSPECT_PORT          |                                                |
| TOPOLOGY_SCAN_FREQUENCY           | 600                                            |
| *ANALYTICS_API_PORT*              | 8081                                           |
| **Authentication**                |                                                |
| AUTH_MODE                         | noauth                                         |
| **Collector**                     |                                                |
| COLLECTOR_SERVERS                 | $ANALYTICS_NODES with $COLLECTOR_PORT          |
| STATS_COLLECTOR_DESTINATION_PATH  |                                                |
| *COLLECTOR_PORT*                  | 8086                                           |
| **Config**                        |                                                |
| CASSANDRA_SSL_CA_CERTFILE         | $SERVER_CA_CERTFILE                            |
| CASSANDRA_SSL_ENABLE              | false                                          |
| CONFIGDB_SERVERS                  | $CONFIGDB_NODES with $CONFIGDB_PORT            |
| CONFIG_API_PORT                   | 8082                                           |
| CONFIG_API_SERVER_CA_CERTFILE     | $SERVER_CA_CERTFILE                            |
| CONFIG_API_SSL_ENABLE             | $SSL_ENABLE                                    |
| CONFIG_API_USE_SSL                |                                                |
| CONFIG_NODES                      | $CONTROLLER_NODES                              |
| CONFIG_SERVERS                    | $CONFIG_NODES with $CONFIG_API_PORT            |
| *CONFIGDB_NODES*                  | $CONFIG_NODES                                  |
| *CONFIGDB_PORT*                   | 9161                                           |
| **Controller**                    |                                                |
| *CONTROLLER_NODES*                | IP address of the NIC performs default routing |
| **Introspect**                    |                                                |
| INTROSPECT_LISTEN_ALL             | True                                           |
| INTROSPECT_SSL_ENABLE             | $SSL_ENABLE                                    |
| **Keystone authentication**       |                                                |
| KEYSTONE_AUTH_ADMIN_PASSWORD      | contrail123                                    |
| KEYSTONE_AUTH_ADMIN_PORT          | 35357                                          |
| KEYSTONE_AUTH_ADMIN_TENANT        | admin                                          |
| KEYSTONE_AUTH_ADMIN_USER          | admin                                          |
| KEYSTONE_AUTH_CA_CERTFILE         |                                                |
| KEYSTONE_AUTH_CERTFILE            |                                                |
| KEYSTONE_AUTH_HOST                | 127.0.0.1                                      |
| KEYSTONE_AUTH_INSECURE            | $SSL_INSECURE                                  |
| KEYSTONE_AUTH_KEYFILE             |                                                |
| KEYSTONE_AUTH_PROJECT_DOMAIN_NAME | Default                                        |
| KEYSTONE_AUTH_PROTO               | http                                           |
| KEYSTONE_AUTH_REGION_NAME         | RegionOne                                      |
| KEYSTONE_AUTH_URL_TOKENS          | /v3/auth/tokens                                |
| KEYSTONE_AUTH_URL_VERSION         | /v3                                            |
| KEYSTONE_AUTH_USER_DOMAIN_NAME    | Default                                        |
| KEYSTONE_AUTH_ENDPOINT_TYPE       |                                                |
| KEYSTONE_AUTH_SYNC_ON_DEMAND      |                                                |
| **Logging**                       |                                                |
| LOG_DIR                           | "/var/log/contrail"                            |
| LOG_LEVEL                         | SYS_NOTICE                                     |
| LOG_LOCAL                         | -1                                             |
| **RabbitMQ**                      |                                                |
| RABBITMQ_CLIENT_SSL_CACERTFILE    | $RABBITMQ_SSL_CACERTFILE                       |
| RABBITMQ_CLIENT_SSL_CERTFILE      | $RABBITMQ_SSL_CERTFILE                         |
| RABBITMQ_CLIENT_SSL_KEYFILE       | $RABBITMQ_SSL_KEYFILE                          |
| RABBITMQ_PASSWORD                 | guest                                          |
| RABBITMQ_SERVERS                  | $RABBITMQ_NODES with $RABBITMQ_NODE_PORT,"     |
| RABBITMQ_SSL_VER                  | sslv23                                         |
| RABBITMQ_USER                     | guest                                          |
| RABBITMQ_USE_SSL                  | False                                          |
| RABBITMQ_VHOST                    | /                                              |
| *RABBITMQ_NODES*                  | $CONFIGDB_NODES                                |
| *RABBITMQ_NODE_PORT*              | 5673                                           |
| *RABBITMQ_SSL_CACERTFILE*         | $SERVER_CA_CERTFILE                            |
| *RABBITMQ_SSL_CERTFILE*           | $SERVER_CERTFILE                               |
| *RABBITMQ_SSL_KEYFILE*            | $SERVER_KEYFILE                                |
| **Sandesh**                       |                                                |
| SANDESH_CA_CERTFILE               | $SERVER_CA_CERTFILE                            |
| SANDESH_CERTFILE                  | $SERVER_CERTFILE                               |
| SANDESH_KEYFILE                   | $SERVER_KEYFILE                                |
| SANDESH_SSL_ENABLE                | $SSL_ENABLE                                    |
| **Server SSL**                    |                                                |
| SSL_ENABLE                        | False                                          |
| *SERVER_CA_CERTFILE*              | /etc/contrail/ssl/certs/ca-cert.pem            |
| *SERVER_CERTFILE*                 | /etc/contrail/ssl/certs/server.pem             |
| *SERVER_KEYFILE*                  | /etc/contrail/ssl/private/server-privkey.pem   |
| *SSL_INSECURE*                    | True                                           |
| **Zookeeper**                     |                                                |
| ZOOKEEPER_SERVERS                 | ZOOKEEPER_NODES with $ZOOKEEPER_PORT           |
| *ZOOKEEPER_NODES*                 | $CONFIGDB_NODES                                |
| *ZOOKEEPER_PORT*                  | 2181                                           |
