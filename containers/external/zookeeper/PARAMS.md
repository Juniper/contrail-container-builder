# contrail-external-zookeeper parameters

| parameters           | default                                        |
| -------------------- | ---------------------------------------------- |
| **Config**           |                                                |
| *CONFIGDB_NODES*     | $CONFIG_NODES                                  |
| *CONFIG_NODES*       | $CONTROLLER_NODES                              |
| **Controller**       |                                                |
| *CONTROLLER_NODES*   | IP address of the NIC performs default routing |
| **Zookeeper**        |                                                |
| MY_ZOO_IP            |                                                |
| ZOOKEEPER_NODES      | $CONFIGDB_NODES                                |
| ZOOKEEPER_PORT       | 2181                                           |
| ZOOKEEPER_PORTS      | 2888:3888                                      |
| ZOO_CONF_DIR         |                                                |
| ZOO_DATA_DIR         |                                                |
| ZOO_DATA_LOG_DIR     |                                                |
| ZOO_INIT_LIMIT       |                                                |
| ZOO_MAX_CLIENT_CNXNS |                                                |
| ZOO_MY_ID            |                                                |
| ZOO_PORT             |                                                |
| ZOO_SERVERS          |                                                |
| ZOO_SYNC_LIMIT       |                                                |
| ZOO_TICK_TIME        |                                                |