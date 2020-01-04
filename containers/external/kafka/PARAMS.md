# contrail-external-kafka parameters

| parameters                           | default                                        |
| ------------------------------------ | ---------------------------------------------- |
| **Analytics**                        |                                                |
| *ANALYTICSDB_NODES*                  | $ANALYTICS_NODES                               |
| *ANALYTICS_ALARM_NODES*              | $ANALYTICS_NODES                               |
| *ANALYTICS_NODES*                    | $CONTROLLER_NODES                              |
| **Controller**                       |                                                |
| *CONTROLLER_NODES*                   | IP address of the NIC performs default routing |
| **Kafka**                            |                                                |
| KAFKA_BROKER_ID                      | 1                                              |
| KAFKA_CONF_DIR                       |                                                |
| KAFKA_DIR                            |                                                |
| KAFKA_KEY_PASSWORD                   | c0ntrail123                                    |
| KAFKA_LISTEN_ADDRESS                 | auto                                           |
| KAFKA_LISTEN_PORT                    | KAFKA_PORT                                     |
| KAFKA_NODES                          | $ANALYTICS_ALARM_NODES                         |
| KAFKA_SSL_CACERTFILE                 | $SERVER_CA_CERTFILE                            |
| KAFKA_SSL_CERTFILE                   | $SERVER_CERTFILE                               |
| KAFKA_SSL_ENABLE                     | $SSL_ENABLE                                    |
| KAFKA_SSL_KEYFILE                    | SERVER_KEYFILE                                 |
| KAFKA_STORE_PASSWORD                 | c0ntrail123                                    |
| KAFKA_delete_topic_enable            | true                                           |
| KAFKA_log_cleaner_dedupe_buffer_size | 250000000                                      |
| KAFKA_log_cleaner_enable             | true                                           |
| KAFKA_log_cleaner_threads            | 2                                              |
| KAFKA_log_cleanup_policy             | delete                                         |
| KAFKA_log_retention_bytes            | 268435456                                      |
| KAFKA_log_retention_hours            | 24                                             |
| KAFKA_log_segment_bytes              | 268435456                                      |
| *KAFKA_PORT*                         | 9092                                           |
| **Server SSL**                       |                                                |
| *SERVER_CA_CERTFILE*                 | /etc/contrail/ssl/certs/ca-cert.pem            |
| *SERVER_CERTFILE*                    | /etc/contrail/ssl/certs/server.pem             |
| *SERVER_KEYFILE*                     | /etc/contrail/ssl/private/server-privkey.pem   |
| *SSL_ENABLE*                         | False                                          |
| **Zookeeper**                        |                                                |
| ZOOKEEPER_SERVERS                    | $ZOOKEEPER_NODES with $ZOOKEEPER_PORT          |
| ZOOKEEPER_SERVERS_SPACE_DELIM        | $ZOOKEEPER_NODES with $ZOOKEEPER_PORT          |