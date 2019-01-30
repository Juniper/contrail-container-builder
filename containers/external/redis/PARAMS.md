# contrail-external-redis parameters

| parameters            | default                                        |
| --------------------- | ---------------------------------------------- |
| **Analytics**         |                                                |
| *ANALYTICS_NODES*     | $CONTROLLER_NODES                              |
| **Controller**        |                                                |
| *CONTROLLER_NODES*    | DEFAULT_LOCAL_IP                               |
| **Host**              |                                                |
| *DEFAULT_LOCAL_IP*    | IP address of the NIC performs default routing |
| **Redis**             |                                                |
| REDIS_LISTEN_ADDRESS  |                                                |
| REDIS_NODES           | ANALYTICS_NODES                                |
| REDIS_PROTECTED_MODE  |                                                |
| REDIS_SERVER_PASSWORD | ""                                             |
| REDIS_SERVER_PORT     | 6379                                           |