# contrail-analytics-alarm-gen parameters

| parameter                          | default                                                                 |
| ---------------------------------- | ----------------------------------------------------------------------- |
| **Alarm generator**                |                                                                         |
| ALARMGEN_INTROSPECT_LISTEN_PORT    | $ALARMGEN_INTROSPECT_PORT                                               |
| ALARMGEN_REDIS_AGGREGATE_DB_OFFSET | -1                                                                      |
| ALARMGEN_partitions                | 30                                                                      |
| ANALYTICS_ALARM_NODES              | $ANALYTICS_NODES                                                        |
| *ALARMGEN_INTROSPECT_PORT*         | 5995                                                                    |
| **Analytics**                      |                                                                         |
| *ANALYTICSDB_NODES*                | $ANALYTICS_NODES                                                        |
| *ANALYTICS_NODES*                  | $CONTROLLER_NODES                                                       |
| **Authentication**                 |                                                                         |
| AUTH_MODE                          | noauth                                                                  |
| **Collector**                      |                                                                         |
| COLLECTOR_SERVERS                  | $ANALYTICS_NODES with $COLLECTOR_PORT                                   |
| STATS_COLLECTOR_DESTINATION_PATH   |                                                                         |
| *COLLECTOR_PORT*                   | 8086                                                                    |
| **Controller**                     |                                                                         |
| *CONTROLLER_NODES*                 | IP address of the NIC performs default routing                          |
| **Config**                         |                                                                         |
| CASSANDRA_SSL_CA_CERTFILE          | $SERVER_CA_CERTFILE                                                     |
| CASSANDRA_SSL_ENABLE               | false                                                                   |
| CONFIGDB_SERVERS                   | $CONFIGDB_NODES with $CONFIGDB_PORT                                     |
| CONFIG_API_SERVER_CA_CERTFILE      | $SERVER_CA_CERTFILE                                                     |
| CONFIG_API_SSL_ENABLE              | $SSL_ENABLE                                                             |
| CONFIG_NODES                       | $CONTROLLER_NODES                                                       |
| CONFIG_SERVERS                     | $CONFIG_NODES with $CONFIG_API_PORT                                     |
| *CONFIGDB_NODES*                   | $CONFIG_NODES                                                           |
| *CONFIGDB_PORT*                    | 9161                                                                    |
| *CONFIG_API_PORT*                  | 8082                                                                    |
| **Introspect**                     |                                                                         |
| INTROSPECT_LISTEN_ALL              | True                                                                    |
| INTROSPECT_SSL_ENABLE              | $SSL_ENABLE                                                             |
| **Logging**                        |                                                                         |
| LOG_DIR                            | /var/log/contrail                                                       |
| LOG_LEVEL                          | SYS_NOTICE                                                              |
| LOG_LOCAL                          | -1                                                                      |
| **Kafka**                          |                                                                         |
| KAFKA_SERVERS                      | $KAFKA_NODES whith $KAFKA_PORT                                          |
| KAFKA_SSL_CACERTFILE               | $SERVER_CA_CERTFILE                                                     |
| KAFKA_SSL_CERTFILE                 | $SERVER_CERTFILE                                                        |
| KAFKA_SSL_ENABLE                   | $SSL_ENABLE                                                             |
| KAFKA_SSL_KEYFILE                  | $SERVER_KEYFILE                                                         |
| *KAFKA_NODES*                      | $ANALYTICS_ALARM_NODES                                                  |
| *KAFKA_PORT*                       | 9092                                                                    |
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
| KEYSTONE_AUTH_USER_DOMAIN_NAME     | Default                                                                 |
| *KEYSTONE_AUTH_URL_VERSION*        | /v3                                                                     |
| KEYSTONE_AUTH_ENDPOINT_TYPE        |                                                                         |
| KEYSTONE_AUTH_SYNC_ON_DEMAND       |                                                                         |
| **RabbitMQ**                       |                                                                         |
| RABBITMQ_CLIENT_SSL_CACERTFILE     | $RABBITMQ_SSL_CACERTFILE                                                |
| RABBITMQ_CLIENT_SSL_CERTFILE       | $RABBITMQ_SSL_CERTFILE                                                  |
| RABBITMQ_CLIENT_SSL_KEYFILE        | $RABBITMQ_SSL_KEYFILE                                                   |
| RABBITMQ_PASSWORD                  | guest                                                                   |
| RABBITMQ_SERVERS                   | $RABBITMQ_NODES with $RABBITMQ_NODE_PORT                                |
| RABBITMQ_SSL_VER                   | sslv23                                                                  |
| RABBITMQ_USER                      | guest                                                                   |
| RABBITMQ_USE_SSL                   | False                                                                   |
| RABBITMQ_VHOST                     | /                                                                       |
| *RABBITMQ_NODES*                   | $CONFIGDB_NODES                                                         |
| *RABBITMQ_NODE_PORT*               | 5673                                                                    |
| *RABBITMQ_SSL_CACERTFILE*          | $SERVER_CA_CERTFILE                                                     |
| *RABBITMQ_SSL_CERTFILE*            | $SERVER_CERTFILE                                                        |
| *RABBITMQ_SSL_KEYFILE*             | $SERVER_KEYFILE                                                         |
| **Redis**                          |                                                                         |
| REDIS_SERVERS                      | $REDIS_NODES with $REDIS_SERVER_PORT                                    |
| REDIS_SERVER_PASSWORD              | ""                                                                      |
| REDIS_SERVER_PORT                  | 6379                                                                    |
| REDIS_SSL_CACERTFILE               | $SERVER_CA_CERTFILE                                                     |
| REDIS_SSL_CERTFILE                 | $SERVER_CERTFILE                                                        |
| REDIS_SSL_ENABLE                   | $SSL_ENABLE                                                             |
| REDIS_SSL_KEYFILE                  | $SERVER_KEYFILE                                                         |
| *REDIS_NODES*                      | $ANALYTICS_NODES                                                        |
| **Sandesh**                        |                                                                         |
| SANDESH_CA_CERTFILE                | $SERVER_CA_CERTFILE                                                     |
| SANDESH_CERTFILE                   | $SERVER_CERTFILE                                                        |
| SANDESH_KEYFILE                    | $SERVER_KEYFILE                                                         |
| SANDESH_SSL_ENABLE                 | $SSL_ENABLE                                                             |
| **Server SSL**                     |                                                                         |
| SSL_ENABLE                         | False                                                                   |
| *SERVER_CA_CERTFILE*               | /etc/contrail/ssl/certs/ca-cert.pem                                     |
| *SERVER_CERTFILE*                  | /etc/contrail/ssl/certs/server.pem                                      |
| *SERVER_KEYFILE*                   | /etc/contrail/ssl/private/server-privkey.pem                            |
| *SSL_INSECURE*                     | True                                                                    |
| **XMPP**                           |                                                                         |
| XMPP_SSL_ENABLE                    | $SSL_ENABLE                                                             |
| **Zookeeper**                      |                                                                         |
| ZOOKEEPER_SERVERS_SPACE_DELIM      | $ZOOKEEPER_NODES with $ZOOKEEPER_PORT                                   |
| *ZOOKEEPER_NODES*                  | $CONFIG_NODES                                                           |
| *ZOOKEEPER_PORT*                   | 2181                                                                    |
