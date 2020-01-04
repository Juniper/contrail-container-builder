# contrail-vcenter-manager parameters

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
| **Host**                     |                                                |
| VROUTER_GATEWAY              |                                                |
| **Introspect**               |                                                |
| INTROSPECT_LISTEN_ALL        | True                                           |
| **Keystone authentication**  |                                                |
| KEYSTONE_AUTH_ADMIN_PASSWORD | contrail123                                    |
| KEYSTONE_AUTH_ADMIN_TENANT   | admin                                          |
| KEYSTONE_AUTH_ADMIN_USERNAME |                                                |
| KEYSTONE_AUTH_HOST           | 127.0.0.1                                      |
| KEYSTONE_AUTH_PUBLIC_PORT    | 5000                                           |
| **Logging**                  |                                                |
| LOG_DIR                      | /var/log/contrail                              |
| LOG_LEVEL                    | SYS_NOTICE                                     |
| **vCenter**                  |                                                |
| ESXI_HOST                    |                                                |
| ESXI_PASSWORD                |                                                |
| ESXI_PORT                    | 443                                            |
| ESXI_USERNAME                |                                                |
| VCENTER_API_VERSION          | vim.version.version10                          |
| VCENTER_DATACENTER           |                                                |
| VCENTER_DVSWITCH             |                                                |
| VCENTER_PASSWORD             |                                                |
| VCENTER_PORT                 | 443                                            |
| VCENTER_SERVER               |                                                |
| VCENTER_USERNAME             |                                                |
