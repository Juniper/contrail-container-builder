# contrail-vcenter-plugin parameters

| parameters                        | default                                        |
| --------------------------------- | ---------------------------------------------- |
| **Config**                        |                                                |
| CONFIG_API_PORT                   | 8082                                           |
| CONFIG_API_SERVER_CA_CERTFILE     | $SERVER_CA_CERTFILE                            |
| CONFIG_API_SSL_ENABLE             | $SSL_ENABLE                                    |
| CONFIG_API_VIP                    | $CONFIG_NODES                                  |
| *CONFIGDB_NODES*                  | $CONFIG_NODES                                  |
| *CONFIG_NODES*                    | $CONTROLLER_NODES                              |
| **Controller**                    |                                                |
| *CONTROLLER_NODES*                | IP address of the NIC performs default routing |
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
| **Server SSL**                    |                                                |
| *SERVER_CA_CERTFILE*              | /etc/contrail/ssl/certs/ca-cert.pem            |
| *SSL_ENABLE*                      | False                                          |
| *SSL_INSECURE*                    | True                                           |
| **vCenter**                       |                                                |
| VCENTER_DATACENTER                |                                                |
| VCENTER_DVSWITCH                  |                                                |
| VCENTER_IPFABRICPG                | contrail-fab-pg                                |
| VCENTER_PASSWORD                  |                                                |
| VCENTER_USERNAME                  |                                                |
| **Zookeeper**                     |                                                |
| ZOOKEEPER_SERVERS                 | ZOOKEEPER_NODES with $ZOOKEEPER_PORT           |
| *ZOOKEEPER_NODES*                 | $CONFIGDB_NODES                                |
| *ZOOKEEPER_PORT*                  | 2181                                           |
