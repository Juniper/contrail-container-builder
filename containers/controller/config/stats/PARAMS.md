# contrail-controller-config-stats parameters

| parameter                         | default                                        |
| --------------------------------- | -----------------------------------------------|
| **DEFAULT**                       |                                                |
| STATS_SERVER                      | http://stats.tungsten.io/api/stats             |
| LOG_DIR                           | /var/log/contrail                              |
| LOG_LEVEL                         | SYS_NOTICE                                     |
| **Authentication**                |                                                |
| AUTH_MODE                         | noauth                                         |
| **Keystone authentication**       |                                                |
| KEYSTONE_AUTH_PROTO               | http                                           |
| KEYSTONE_AUTH_HOST                | 127.0.0.1                                      |
| KEYSTONE_AUTH_ADMIN_PORT          | 35357                                          |
| KEYSTONE_AUTH_URL_TOKENS          | /v3/auth/tokens                                |
| KEYSTONE_AUTH_PROJECT_DOMAIN_NAME | Default                                        |
| KEYSTONE_AUTH_INSECURE            | $SSL_INSECURE                                  |
| KEYSTONE_AUTH_CERTFILE            |                                                |
| KEYSTONE_AUTH_KEYFILE             |                                                |
| KEYSTONE_AUTH_CA_CERTFILE         |                                                |
| **Config**                        |                                                |
| CONFIG_NODES                      | $CONTROLLER_NODES                              |
| CONFIG_API_PORT                   | 8082                                           |
| CONFIG_API_SSL_ENABLE             | $SSL_ENABLE                                    |
| CONFIG_API_SERVER_CA_CERTFILE     | $SERVER_CA_CERTFILE                            |
