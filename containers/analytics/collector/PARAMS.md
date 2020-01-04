# contrail-analytics-collector parameters

| parameter                                          | default                                                                 |
| -------------------------------------------------- | ----------------------------------------------------------------------- |
| **Analytics**                                      |                                                                         |
| ANALYTICSDB_CQL_SERVERS                            | $ANALYTICSDB_NODES with $ANALYTICSDB_CQL_PORT                           |
| ANALYTICSDB_ENABLE                                 | False                                                                   |
| ANALYTICS_ALARM_ENABLE                             | False                                                                   |
| ANALYTICS_CONFIG_AUDIT_TTL                         | 2160                                                                    |
| ANALYTICS_DATA_TTL                                 | 48                                                                      |
| ANALYTICS_FLOW_TTL                                 | 2                                                                       |
| ANALYTICS_NODES                                    | $CONTROLLER_NODES                                                       |
| ANALYTICS_STATISTICS_TTL                           | 168                                                                     |
| ANALYTICS_UVE_PARTITIONS                           | 30                                                                      |
| CASSANDRA_SSL_CA_CERTFILE                          | $SERVER_CA_CERTFILE                                                     |
| CASSANDRA_SSL_ENABLE                               | false                                                                   |
| *ANALYTICSDB_CQL_PORT*                             | 9042                                                                    |
| *ANALYTICSDB_NODES*                                | $ANALYTICS_NODES                                                        |
| *ANALYTICS_ALARM_NODES*                            | $ANALYTICSDB_NODES                                                      |
| **Authentication**                                 |                                                                         |
| AUTH_MODE                                          | noauth                                                                  |
| **Сollector**                                      |                                                                         |
| COLLECTOR_INTROSPECT_LISTEN_PORT                   | $COLLECTOR_INTROSPECT_PORT                                              |
| COLLECTOR_IPFIX_LISTEN_PORT                        | $COLLECTOR_IPFIX_PORT                                                   |
| COLLECTOR_LISTEN_PORT                              | $COLLECTOR_PORT                                                         |
| COLLECTOR_PROTOBUF_LISTEN_PORT                     | $COLLECTOR_PROTOBUF_PORT                                                |
| COLLECTOR_SFLOW_LISTEN_PORT                        | $COLLECTOR_SFLOW_PORT                                                   |
| COLLECTOR_STRUCTURED_SYSLOG_LISTEN_PORT            | $COLLECTOR_STRUCTURED_SYSLOG_PORT                                       |
| COLLECTOR_SYSLOG_LISTEN_PORT                       | $COLLECTOR_SYSLOG_PORT                                                  |
| COLLECTOR_disk_usage_percentage_high_watermark0    | 90                                                                      |
| COLLECTOR_disk_usage_percentage_high_watermark1    | 80                                                                      |
| COLLECTOR_disk_usage_percentage_high_watermark2    | 70                                                                      |
| COLLECTOR_disk_usage_percentage_low_watermark0     | 85                                                                      |
| COLLECTOR_disk_usage_percentage_low_watermark1     | 75                                                                      |
| COLLECTOR_disk_usage_percentage_low_watermark2     | 60                                                                      |
| COLLECTOR_high_watermark0_message_severity_level   | SYS_EMERG                                                               |
| COLLECTOR_high_watermark1_message_severity_level   | SYS_ERR                                                                 |
| COLLECTOR_high_watermark2_message_severity_level   | SYS_DEBUG                                                               |
| COLLECTOR_low_watermark0_message_severity_level    | SYS_ALERT                                                               |
| COLLECTOR_low_watermark1_message_severity_level    | SYS_WARN                                                                |
| COLLECTOR_low_watermark2_message_severity_level    | INVALID                                                                 |
| COLLECTOR_pending_compaction_tasks_high_watermark0 | 400                                                                     |
| COLLECTOR_pending_compaction_tasks_high_watermark1 | 200                                                                     |
| COLLECTOR_pending_compaction_tasks_high_watermark2 | 100                                                                     |
| COLLECTOR_pending_compaction_tasks_low_watermark0  | 300                                                                     |
| COLLECTOR_pending_compaction_tasks_low_watermark1  | 150                                                                     |
| COLLECTOR_pending_compaction_tasks_low_watermark2  | 80                                                                      |
| STATS_COLLECTOR_DESTINATION_PATH                   |                                                                         |
| *COLLECTOR_INTROSPECT_PORT*                        | 8089                                                                    |
| *COLLECTOR_IPFIX_PORT*                             | 4739                                                                    |
| *COLLECTOR_PORT*                                   | 8086                                                                    |
| *COLLECTOR_PROTOBUF_PORT*                          | 3333                                                                    |
| *COLLECTOR_SFLOW_PORT*                             | 6343                                                                    |
| *COLLECTOR_STRUCTURED_SYSLOG_PORT*                 | 3514                                                                    |
| *COLLECTOR_SYSLOG_PORT*                            | 514                                                                     |
| **Сonfig**                                         |                                                                         |
| CASSANDRA_SSL_CA_CERTFILE                          | $SERVER_CA_CERTFILE                                                     |
| CASSANDRA_SSL_ENABLE                               | false                                                                   |
| CONFIGDB_CQL_SERVERS                               | $CONFIGDB_NODES with $CONFIGDB_CQL_PORT                                 |
| CONFIG_API_PORT                                    | 8082                                                                    |
| CONFIG_API_SERVER_CA_CERTFILE                      | $SERVER_CA_CERTFILE                                                     |
| CONFIG_API_SSL_ENABLE                              | $SSL_ENABLE                                                             |
| CONFIG_NODES                                       | $CONTROLLER_NODES                                                       |
| CONFIG_SERVERS                                     | $CONFIG_NODES with $CONFIG_API_PORT                                     |
| *CONFIGDB_CQL_PORT*                                | 9041                                                                    |
| *CONFIGDB_NODES*                                   | $CONFIG_NODES                                                           |
| *CONFIG_API_PORT*                                  | 8082                                                                    |
| **Controller**                                     |                                                                         |
| *CONTROLLER_NODES*                                 | IP address of the NIC performs default routing                          |
| **Introspect**                                     |                                                                         |
| INTROSPECT_LISTEN_ALL                              | True                                                                    |
| INTROSPECT_SSL_ENABLE                              | $SSL_ENABLE                                                             |
| **Kafka**                                          |                                                                         |
| KAFKA_PARTITIONS                                   | 30                                                                      |
| KAFKA_SERVERS                                      | $KAFKA_NODES with $KAFKA_PORT                                           |
| KAFKA_SSL_CACERTFILE                               | SERVER_CA_CERTFILE                                                      |
| KAFKA_SSL_CERTFILE                                 | SERVER_CERTFILE                                                         |
| KAFKA_SSL_ENABLE                                   | $SSL_ENABLE                                                             |
| KAFKA_SSL_KEYFILE                                  | SERVER_KEYFILE                                                          |
| KAFKA_TOPIC                                        | structured_syslog_topic                                                 |
| *KAFKA_NODES*                                      | $ANALYTICS_ALARM_NODES                                                  |
| *KAFKA_PORT*                                       | 9092                                                                    |
| **Keystone authentication**                        |                                                                         |
| KEYSTONE_AUTH_ADMIN_PASSWORD                       | contrail123                                                             |
| KEYSTONE_AUTH_ADMIN_PORT                           | 35357                                                                   |
| KEYSTONE_AUTH_ADMIN_TENANT                         | admin                                                                   |
| KEYSTONE_AUTH_ADMIN_USER                           | admin                                                                   |
| KEYSTONE_AUTH_CA_CERTFILE                          |                                                                         |
| KEYSTONE_AUTH_CERTFILE                             |                                                                         |
| KEYSTONE_AUTH_HOST                                 | 127.0.0.1                                                               |
| KEYSTONE_AUTH_INSECURE                             | $SSL_INSECURE                                                           |
| KEYSTONE_AUTH_KEYFILE                              |                                                                         |
| KEYSTONE_AUTH_PROJECT_DOMAIN_NAME                  | Default                                                                 |
| KEYSTONE_AUTH_PROTO                                | http                                                                    |
| KEYSTONE_AUTH_REGION_NAME                          | RegionOne                                                               |
| KEYSTONE_AUTH_URL_TOKENS                           | /v3/auth/tokens or /v2.0/tokens in depned on $KEYSTONE_AUTH_URL_VERSION |
| KEYSTONE_AUTH_URL_VERSION                          | /v3                                                                     |
| KEYSTONE_AUTH_USER_DOMAIN_NAME                     | Default                                                                 |
| *KEYSTONE_AUTH_URL_VERSION*                        | /v3                                                                     |
| KEYSTONE_AUTH_ENDPOINT_TYPE                        |                                                                         |
| KEYSTONE_AUTH_SYNC_ON_DEMAND                       |                                                                         |
| **Logging**                                        |                                                                         |
| COLLECTOR_LOG_FILE_COUNT                           | 10                                                                      |
| COLLECTOR_LOG_FILE_SIZE                            | 1048576                                                                 |
| LOG_DIR                                            | /var/log/contrail                                                       |
| LOG_LEVEL                                          | SYS_NOTICE                                                              |
| LOG_LOCAL                                          | -1                                                                      |
| **RabbitMQ**                                       |                                                                         |
| RABBITMQ_CLIENT_SSL_CACERTFILE                     | $RABBITMQ_SSL_CACERTFILE                                                |
| RABBITMQ_CLIENT_SSL_CERTFILE                       | $RABBITMQ_SSL_CERTFILE                                                  |
| RABBITMQ_CLIENT_SSL_KEYFILE                        | $RABBITMQ_SSL_KEYFILE                                                   |
| RABBITMQ_PASSWORD                                  | guest                                                                   |
| RABBITMQ_SERVERS                                   | $RABBITMQ_NODES with $RABBITMQ_NODE_PORT                                |
| RABBITMQ_SSL_VER                                   | sslv23                                                                  |
| RABBITMQ_USER                                      | guest                                                                   |
| RABBITMQ_USE_SSL                                   | False                                                                   |
| RABBITMQ_VHOST                                     | /                                                                       |
| *RABBITMQ_NODES*                                   | $CONFIGDB_NODES                                                         |
| *RABBITMQ_NODE_PORT*                               | 5673                                                                    |
| *RABBITMQ_SSL_CACERTFILE*                          | $SERVER_CA_CERTFILE                                                     |
| *RABBITMQ_SSL_CERTFILE*                            | $SERVER_CERTFILE                                                        |
| *RABBITMQ_SSL_KEYFILE*                             | $SERVER_KEYFILE                                                         |
| **Redis**                                          |                                                                         |
| REDIS_SERVER_PASSWORD                              | ""                                                                      |
| REDIS_SERVER_PORT                                  | 6379                                                                    |
| **Sandesh**                                        |                                                                         |
| SANDESH_CA_CERTFILE                                | $SERVER_CA_CERTFILE                                                     |
| SANDESH_CERTFILE                                   | $SERVER_CERTFILE                                                        |
| SANDESH_KEYFILE                                    | $SERVER_KEYFILE                                                         |
| SANDESH_SSL_ENABLE                                 | $SSL_ENABLE                                                             |
| **Server SSL**                                     |                                                                         |
| *SERVER_CA_CERTFILE*                               | /etc/contrail/ssl/certs/ca-cert.pem                                     |
| *SERVER_CERTFILE*                                  | /etc/contrail/ssl/certs/server.pem                                      |
| *SERVER_KEYFILE*                                   | /etc/contrail/ssl/private/server-privkey.pem                            |
| *SSL_ENABLE*                                       | False                                                                   |
| *SSL_INSECURE*                                     | True                                                                    |
| **Zookeeper**                                      |                                                                         |
| ZOOKEEPER_SERVERS                                  | $ZOOKEEPER_NODES with $ZOOKEEPER_PORT                                   |
| *ZOOKEEPER_NODES*                                  | $CONFIGDB_NODES                                                         |
| *ZOOKEEPER_PORT*                                   | 2181                                                                    |
