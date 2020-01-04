# contrail-vcenter-fabric-manager parameters

| parameters                   | default                                        |
| ---------------------------- | ---------------------------------------------- |
| **Analytics**                |                                                |
| *ANALYTICS_NODES*            | $CONTROLLER_NODES                              |
| **Collector**                |                                                |
| COLLECTOR_SERVERS            | $ANALYTICS_NODES with $COLLECTOR_PORT          |
| *COLLECTOR_PORT*             | 8086                                           |
| **Config**                   |                                                |
| CONFIG_API_PORT              | 8082                                           |
| CONFIG_NODES                 | $CONTROLLER_NODES                              |
| **Control**                  |                                                |
| CONTROL_NODES                | $CONFIG_NODES                                  |
| **Controller**               |                                                |
| *CONTROLLER_NODES*           | IP address of the NIC performs default routing |
| **Introspect**               |                                                |
| INTROSPECT_LISTEN_ALL        | True                                           |
| INTROSPECT_SSL_ENABLE        | $SSL_ENABLE                                    |
| **Keystone authentication**  |                                                |
| KEYSTONE_AUTH_ADMIN_PASSWORD | contrail123                                    |
| KEYSTONE_AUTH_ADMIN_TENANT   | admin                                          |
| KEYSTONE_AUTH_ADMIN_USER     | admin                                          |
| KEYSTONE_AUTH_HOST           | 127.0.0.1                                      |
| KEYSTONE_AUTH_PUBLIC_PORT    | 5000                                           |
| KEYSTONE_AUTH_INSECURE       | $SSL_INSECURE                                  |
| KEYSTONE_AUTH_PROTO          | http                                           |
| KEYSTONE_AUTH_CA_CERTFILE    |                                                |
| KEYSTONE_AUTH_CERTFILE       |                                                |
| KEYSTONE_AUTH_KEYFILE        |                                                |
| KEYSTONE_AUTH_URL_TOKENS     | /v3/auth/tokens                                |
| **Sandesh**                  |                                                |
| SANDESH_CA_CERTFILE          | $SERVER_CA_CERTFILE                            |
| SANDESH_CERTFILE             | $SERVER_CERTFILE                               |
| SANDESH_KEYFILE              | $SERVER_KEYFILE                                |
| SANDESH_SSL_ENABLE           | $SSL_ENABLE                                    |
| **Logging**                  |                                                |
| LOG_DIR                      | /var/log/contrail                              |
| LOG_LEVEL                    | SYS_NOTICE                                     |
| **vCenter**                  |                                                |
| VCENTER_API_VERSION          | vim.version.version10                          |
| VCENTER_DATACENTER           |                                                |
| VCENTER_PASSWORD             |                                                |
| VCENTER_PORT                 | 443                                            |
| VCENTER_SERVER               |                                                |
| VCENTER_USERNAME             |                                                |
| **Server SSL**               |                                                |
| SSL_ENABLE                   | False                                          |
| SERVER_CA_CERTFILE           | /etc/contrail/ssl/certs/ca-cert.pem            |
| SERVER_CERTFILE              | /etc/contrail/ssl/certs/server.pem             |
| SERVER_KEYFILE               | /etc/contrail/ssl/private/server-privkey.pem   |
| SSL_INSECURE                 | True                                           |
| **Zookeeper**                |                                                |
| ZOOKEEPER_SERVERS            | $ZOOKEEPER_NODES with $ZOOKEEPER_PORT          |
