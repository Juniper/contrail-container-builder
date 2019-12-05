# contrail-openstack-ironic-notification-manager parameters

| parameters                                  | default                                      |
| ------------------------------------------- | -------------------------------------------- |
| **Analytics**                               |                                              |
| *ANALYTICS_NODES*                           | $ANALYTICS_NODES                             |
| **Authentication**                          |                                              |
| AUTH_MODE                                   | noauth                                       |
| **Collector**                               |                                              |
| COLLECTOR_SERVERS                           | $ANALYTICS_NODES with $COLLECTOR_PORT        |
| *COLLECTOR_PORT*                            | 8086                                         |
| **Config**                                  |                                              |
| CONFIG_API_PORT                             | 8082                                         |
| CONFIG_API_SERVER_CA_CERTFILE               | $SERVER_CA_CERTFILE                          |
| CONFIG_API_SSL_ENABLE                       | $SSL_ENABLE                                  |
| CONFIG_NODES                                | $CONTROLLER_NODES                            |
| **OpenStack**                               |                                              |
| IRONIC_NOTIFICATION_LEVEL                   |                                              |
| IRONIC_NOTIFICATION_MANAGER_INTROSPECT_PORT | 8110                                         |
| **Keystone authentication**                 |                                              |
| KEYSTONE_AUTH_ADMIN_PORT                    | 35357                                        |
| KEYSTONE_AUTH_CA_CERTFILE                   |                                              |
| KEYSTONE_AUTH_CERTFILE                      |                                              |
| KEYSTONE_AUTH_HOST                          | 127.0.0.1                                    |
| KEYSTONE_AUTH_INSECURE                      | $SSL_INSECURE                                |
| KEYSTONE_AUTH_KEYFILE                       |                                              |
| KEYSTONE_AUTH_PROJECT_DOMAIN_NAME           | Default                                      |
| KEYSTONE_AUTH_PROTO                         | http                                         |
| KEYSTONE_AUTH_URL_TOKENS                    | /v3/auth/tokens                              |
| KEYSTONE_AUTH_ENDPOINT_TYPE                 |                                              |
| KEYSTONE_AUTH_SYNC_ON_DEMAND                |                                              |
| **Logging**                                 |                                              |
| LOG_DIR                                     | /var/log/contrail                            |
| LOG_LEVEL                                   | SYS_NOTICE                                   |
| LOG_LOCAL                                   | 1                                            |
| **RabbitMQ**                                |                                              |
| RABBITMQ_CLIENT_SSL_CACERTFILE              | $RABBITMQ_SSL_CACERTFILE                     |
| RABBITMQ_CLIENT_SSL_CERTFILE                | $RABBITMQ_SSL_CERTFILE                       |
| RABBITMQ_CLIENT_SSL_KEYFILE                 | $RABBITMQ_SSL_KEYFILE                        |
| RABBITMQ_HEARTBEAT_INTERVAL                 | 10                                           |
| RABBITMQ_NODE_PORT                          | 5673                                         |
| RABBITMQ_PASSWORD                           | guest                                        |
| RABBITMQ_SERVERS                            | $RABBITMQ_NODES with $RABBITMQ_NODE_PORT     |
| RABBITMQ_SSL_VER                            | sslv23                                       |
| RABBITMQ_USER                               | guest                                        |
| RABBITMQ_USE_SSL                            | False                                        |
| RABBITMQ_VHOST                              | /                                            |
| *RABBITMQ_NODES*                            | $CONFIGDB_NODES                              |
| *RABBITMQ_SSL_CACERTFILE*                   | $SERVER_CA_CERTFILE                          |
| *RABBITMQ_SSL_CERTFILE*                     | $SERVER_CERTFILE                             |
| *RABBITMQ_SSL_KEYFILE*                      | $SERVER_KEYFILE                              |
| **Server SSL**                              |                                              |
| *SERVER_CA_CERTFILE*                        | /etc/contrail/ssl/certs/ca-cert.pem          |
| *SERVER_CERTFILE*                           | /etc/contrail/ssl/certs/server.pem           |
| *SERVER_KEYFILE*                            | /etc/contrail/ssl/private/server-privkey.pem |