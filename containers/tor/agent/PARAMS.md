# contrail-tor parameters

| parameter               | default                                        |
| ----------------------- | ---------------------------------------------- |
| **Analytics**           |                                                |
| *ANALYTICS_NODES*       | $CONTROLLER_NODES                              |
| **Collector**           |                                                |
| *COLLECTOR_PORT*        | 8086                                           |
| COLLECTOR_SERVERS       | $ANALYTICS_NODES with $COLLECTOR_PORT          |
| **Config**              |                                                |
| *CONFIG_NODES*          | $CONTROLLER_NODES                              |
| **Control**             |                                                |
| *CONTROL_NODES*         | $CONFIG_NODES                                  |
| **Controller**          |                                                |
| *CONTROLLER_NODES*      | IP address of the NIC performs default routing |
| **Introspect**          |                                                |
| INTROSPECT_SSL_ENABLE   | $SSL_ENABLE                                    |
| **Logging**             |                                                |
| LOG_LEVEL               | SYS_NOTICE                                     |
| LOG_LOCAL               | 1                                              |
| **Sandesh**             |                                                |
| SANDESH_CA_CERTFILE     | $SERVER_CA_CERTFILE                            |
| SANDESH_CERTFILE        | $SERVER_CERTFILE                               |
| SANDESH_CA_CERTFILE     | $SERVER_CA_CERTFILE                            |
| SANDESH_SSL_ENABLE      | $SSL_ENABLE                                    |
| **Server SSL**          |                                                |
| *SERVER_CA_CERTFILE*    | /etc/contrail/ssl/certs/ca-cert.pem            |
| *SERVER_CERTFILE*       | /etc/contrail/ssl/certs/server.pem             |
| *SERVER_KEYFILE*        | /etc/contrail/ssl/private/server-privkey.pem   |
| SSL_ENABLE              | False                                          |
| **Tor**                 |                                                |
| TOR_AGENT_ID            |                                                |
| TOR_AGENT_NAME          |                                                |
| TOR_AGENT_OVS_KA        | 10000                                          |
| TOR_HTTP_SERVER_PORT    |                                                |
| TOR_IP                  |                                                |
| TOR_NAME                |                                                |
| TOR_OVS_PORT            |                                                |
| TOR_PRODUCT_NAME        |                                                |
| TOR_OVS_PROTOCOL        | tcp                                            |
| TOR_TSN_IP              |                                                |
| TOR_TYPE                | ovs                                            |
| TOR_VENDOR_NAME         |                                                |
| TORAGENT_SSL_CACERTFILE | $SERVER_CA_CERTFILE                            |
| TORAGENT_SSL_CERTFILE   | $SERVER_CERTFILE                               |
| TORAGENT_SSL_KEYFILE    | $SERVER_KEYFILE                                |
| TOR_OVS_PROTOCOL        | tcp                                            |
| **vRouter**             |                                                |
| VROUTER_GATEWAY         |
| **XMPP**                |                                                |
| XMPP_SERVER_CA_CERTFILE | $SERVER_CA_CERTFILE                            |
| XMPP_SERVER_CERTFILE    | $SERVER_CERTFILE                               |
| XMPP_SERVER_KEYFILE     | $SERVER_KEYFILE                                |
| XMPP_SERVER_PORT        | 5269                                           |
| XMPP_SERVERS            | $CONTROL_NODES with $XMPP_SERVER_PORT          |
| XMPP_SSL_ENABLE         | $SSL_ENABLE                                    |