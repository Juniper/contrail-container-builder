# contrail-analytics-query-engine parameters

| parameter                          | default                                                                 |
| ---------------------------------- | ----------------------------------------------------------------------- |
| **Фnalytics**                      |                                                                         |
| ANALYTICSDB_CQL_SERVERS            | $ANALYTICSDB_NODES with $ANALYTICSDB_CQL_PORT                           |
| ANALYTICS_DATA_TTL                 | 48                                                                      |
| ANALYTICSDB_NODES                  | $ANALYTICS_NODES                                                        |
| CASSANDRA_SSL_CA_CERTFILE          | $SERVER_CA_CERTFILE                                                     |
| CASSANDRA_SSL_ENABLE               | false                                                                   |
| QUERYENGINE_INTROSPECT_LISTEN_PORT | $QUERYENGINE_INTROSPECT_PORT                                            |
| QUERYENGINE_INTROSPECT_PORT        | 8091                                                                    |
| QUERYENGINE_MAX_SLICE              | 100                                                                     |
| QUERYENGINE_MAX_TASKS              | 16                                                                      |
| QUERYENGINE_START_TIME             | 0                                                                       |
| *ANALYTICSDB_CQL_PORT*             | 9042                                                                    |
| *ANALYTICS_NODES*                  | $CONTROLLER_NODES                                                       |
| **Authentication**                 |                                                                         |
| AUTH_MODE                          | noauth                                                                  |
| **Сollector**                      |                                                                         |
| COLLECTOR_SERVERS                  | $ANALYTICS_NODES with $COLLECTOR_PORT                                   |
| STATS_COLLECTOR_DESTINATION_PATH   |                                                                         |
| *COLLECTOR_PORT*                   | 8086                                                                    |
| **Config**                         |                                                                         |
| CONFIG_API_PORT                    | 8082                                                                    |
| CONFIG_API_SERVER_CA_CERTFILE      | $SERVER_CA_CERTFILE                                                     |
| CONFIG_API_SSL_ENABLE              | $SSL_ENABLE                                                             |
| CONFIG_NODES                       | $CONTROLLER_NODES                                                       |
| **Controller**                     |                                                                         |
| *CONTROLLER_NODES*                 | IP address of the NIC performs default routing                          |
| **Introspect**                     |                                                                         |
| INTROSPECT_LISTEN_ALL              | True                                                                    |
| INTROSPECT_SSL_ENABLE              | $SSL_ENABLE                                                             |
| **Keystone authentication**        |                                                                         |
| KEYSTONE_AUTH_ADMIN_PASSWORD       | contrail123                                                             |
| KEYSTONE_AUTH_ADMIN_PORT           | 35357                                                                   |
| KEYSTONE_AUTH_ADMIN_TENANT         | admin                                                                   |
| KEYSTONE_AUTH_ADMIN_USER           | admin                                                                   |
| KEYSTONE_AUTH_CA_CERTFILE          |                                                                         |
| KEYSTONE_AUTH_CERTFILE             |                                                                         |
| KEYSTONE_AUTH_HOST                 | 127.0.0.1                                                               |
| KEYSTONE_AUTH_INSECURE             | $SSL_INSECURE                                                           |
| KEYSTONE_AUTH_KEYFILE              |                                                                         |
| KEYSTONE_AUTH_PROJECT_DOMAIN_NAME  | Default                                                                 |
| KEYSTONE_AUTH_PROTO                | http                                                                    |
| KEYSTONE_AUTH_REGION_NAME          | RegionOne                                                               |
| KEYSTONE_AUTH_URL_TOKENS           | /v3/auth/tokens or /v2.0/tokens in depned on $KEYSTONE_AUTH_URL_VERSION |
| KEYSTONE_AUTH_URL_VERSION          | /v3                                                                     |
| KEYSTONE_AUTH_USER_DOMAIN_NAME     | Default                                                                 |
| *KEYSTONE_AUTH_URL_VERSION*        | /v3                                                                     |
| KEYSTONE_AUTH_ENDPOINT_TYPE        |                                                                         |
| KEYSTONE_AUTH_SYNC_ON_DEMAND       |                                                                         |
| **Logging**                        |                                                                         |
| LOG_DIR                            | /var/log/contrail                                                       |
| LOG_LEVEL                          | SYS_NOTICE                                                              |
| LOG_LOCAL                          | -1                                                                      |
| **Redis**                          |                                                                         |
| REDIS_SERVERS                      | $REDIS_NODES with $REDIS_SERVER_PORT                                    |
| REDIS_SERVER_PASSWORD              | ""                                                                      |
| *REDIS_NODES*                      | $ANALYTICS_NODES                                                        |
| REDIS_SSL_CACERTFILE               | $SERVER_CA_CERTFILE                                                     |
| REDIS_SSL_CERTFILE                 | $SERVER_CERTFILE                                                        |
| REDIS_SSL_ENABLE                   | $SSL_ENABLE                                                             |
| REDIS_SSL_KEYFILE                  | $SERVER_KEYFILE                                                         |
| **Sandesh**                        |                                                                         |
| SANDESH_CA_CERTFILE                | $SERVER_CA_CERTFILE                                                     |
| SANDESH_CERTFILE                   | $SERVER_CERTFILE                                                        |
| SANDESH_KEYFILE                    | $SERVER_KEYFILE                                                         |
| SANDESH_SSL_ENABLE                 | $SSL_ENABLE                                                             |
| **Server SSL**                     |                                                                         |
| *SERVER_CA_CERTFILE*               | /etc/contrail/ssl/certs/ca-cert.pem                                     |
| *SERVER_CERTFILE*                  | /etc/contrail/ssl/certs/server.pem                                      |
| *SERVER_KEYFILE*                   | /etc/contrail/ssl/private/server-privkey.pem                            |
| *SSL_ENABLE*                       | False                                                                   |
| *SSL_INSECURE*                     | True                                                                    |
