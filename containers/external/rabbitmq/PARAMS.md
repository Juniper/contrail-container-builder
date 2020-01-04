# contrail-external-rabbitmq parameters

| parameters                        | default                                        |
| --------------------------------- | ---------------------------------------------- |
| **Config**                        |                                                |
| *CONFIGDB_NODES*                  | $CONFIG_NODES                                  |
| *CONFIG_NODES*                    | $CONTROLLER_NODES                              |
| **Controller**                    |                                                |
| *CONTROLLER_NODES*                | IP address of the NIC performs default routing |
| **RabbitMQ**                      |                                                |
| RABBITMQ_ERLANG_COOKIE            |                                                |
| RABBITMQ_HEARTBEAT_INTERVAL       | 10                                             |
| RABBITMQ_NODES                    | $CONFIGDB_NODES                                |
| RABBITMQ_NODE_PORT                | 5673                                           |
| RABBITMQ_PASSWORD                 | guest                                          |
| RABBITMQ_SSL_CACERTFILE           | $SERVER_CA_CERTFILE                            |
| RABBITMQ_SSL_CERTFILE             | $SERVER_CERTFILE                               |
| RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT | true                                           |
| RABBITMQ_SSL_KEYFILE              | $SERVER_KEYFILE                                |
| RABBITMQ_USER                     | guest                                          |
| RABBITMQ_USE_SSL                  | False                                          |
| RABBITMQ_MIRRORED_QUEUE_MODE      |                                                |
| **Server SSL**                    |                                                |
| *SERVER_CA_CERTFILE*              | /etc/contrail/ssl/certs/ca-cert.pem            |
| *SERVER_CERTFILE*                 | /etc/contrail/ssl/certs/server.pem             |
| *SERVER_KEYFILE*                  | /etc/contrail/ssl/private/server-privkey.pem   |
