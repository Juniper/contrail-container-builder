# contrail-vrouter-agent parameters

| parameters                         | default                                             |
| ---------------------------------- | --------------------------------------------------- |
| **Analytics**                      |                                                     |
| *ANALYTICS_NODES*                  | $CONTROLLER_NODES                                   |
| **Cloud orchestration**            |                                                     |
| CLOUD_ORCHESTRATOR                 | none                                                |
| HYPERVISOR_TYPE                    | kvm                                                 |
| HYPERVISOR_TYPE                    | vmware                                              |
| **Collector**                      |                                                     |
| COLLECTOR_SERVERS                  | $ANALYTICS_NODES with $COLLECTOR_PORT               |
| STATS_COLLECTOR_DESTINATION_PATH   |                                                     |
| *COLLECTOR_PORT*                   | 8086                                                |
| **Config**                         |                                                     |
| CONFIG_API_PORT                    | 8082                                                |
| CONFIG_API_SERVER_CA_CERTFILE      |                                                     |
| CONFIG_API_SSL_ENABLE              | $SSL_ENABLE                                         |
| *CONFIG_NODES*                     | $CONTROLLER_NODES                                   |
| **Control**                        |                                                     |
| CONTROL_NODES                      | $CONFIG_NODES                                       |
| **Controller**                     |                                                     |
| *CONTROLLER_NODES*                 | IP address of the NIC performs default routing      |
| **DNS**                            |                                                     |
| DNS_SERVERS                        | $DNS_NODES with $DNS_SERVER_PORT                    |
| *DNS_NODES*                        | $CONTROL_NODES                                      |
| *DNS_SERVER_PORT*                  | 53                                                  |
| **Host**                           |                                                     |
| DPDK_UIO_DRIVER                    | uio_pci_generic                                     |
| PHYSICAL_INTERFACE                 |                                                     |
| SRIOV_PHYSICAL_INTERFACE           |                                                     |
| SRIOV_VF                           |                                                     |
| **Introspect**                     |                                                     |
| INTROSPECT_LISTEN_ALL              | True                                                |
| INTROSPECT_SSL_ENABLE              | $SSL_ENABLE                                         |
| **Keystone authentication**        |                                                     |
| KEYSTONE_AUTH_ADMIN_PORT           | 35357                                               |
| KEYSTONE_AUTH_CA_CERTFILE          |                                                     |
| KEYSTONE_AUTH_CERTFILE             |                                                     |
| KEYSTONE_AUTH_HOST                 | 127.0.0.1                                           |
| KEYSTONE_AUTH_INSECURE             | $SSL_INSECURE                                       |
| KEYSTONE_AUTH_KEYFILE              |                                                     |
| KEYSTONE_AUTH_PROJECT_DOMAIN_NAME  | Default                                             |
| KEYSTONE_AUTH_PROTO                | http                                                |
| KEYSTONE_AUTH_REGION_NAME          | RegionOne                                           |
| KEYSTONE_AUTH_URL_TOKENS           | /v3/auth/tokens                                     |
| KEYSTONE_AUTH_URL_VERSION          | /v3                                                 |
| KEYSTONE_AUTH_USER_DOMAIN_NAME     | Default                                             |
| *KEYSTONE_AUTH_ADMIN_PASSWORD*     | contrail123                                         |
| **Kubernetes**                     |                                                     |
| K8S_TOKEN                          | cat                                                 |
| K8S_TOKEN_FILE                     | /var/run/secrets/kubernetes.io/serviceaccount/token |
| KUBERNETES_API_PORT                | 8080                                                |
| KUBERNETES_API_SECURE_PORT         | 6443                                                |
| KUBERNETES_API_SERVER              | IP address of the NIC performs default routing      |
| KUBERNETES_POD_SUBNETS             | 10.32.0.0/12                                        |
| **Logging**                        |                                                     |
| LOG_DIR                            | /var/log/contrail                                   |
| LOG_LEVEL                          | SYS_NOTICE                                          |
| LOG_LOCAL                          | 1                                                   |
| **Metadata**                       |                                                     |
| METADATA_PROXY_SECRET              | contrail                                            |
| METADATA_SSL_CA_CERTFILE           |                                                     |
| METADATA_SSL_CERTFILE              |                                                     |
| METADATA_SSL_CERT_TYPE             |                                                     |
| METADATA_SSL_ENABLE                | false                                               |
| METADATA_SSL_KEYFILE               |                                                     |
| **OpenStack**                      |                                                     |
| BARBICAN_PASSWORD                  | $KEYSTONE_AUTH_ADMIN_PASSWORD                       |
| BARBICAN_USER                      | barbican                                            |
| **Sandesh**                        |                                                     |
| SANDESH_CA_CERTFILE                | $SERVER_CA_CERTFILE                                 |
| SANDESH_CERTFILE                   | $SERVER_CERTFILE                                    |
| SANDESH_KEYFILE                    | $SERVER_KEYFILE                                     |
| SANDESH_SSL_ENABLE                 | $SSL_ENABLE                                         |
| **Server SSL**                     |                                                     |
| *SERVER_CA_CERTFILE*               | /etc/contrail/ssl/certs/ca-cert.pem                 |
| *SERVER_CERTFILE*                  | /etc/contrail/ssl/certs/server.pem                  |
| *SERVER_KEYFILE*                   | /etc/contrail/ssl/private/server-privkey.pem        |
| *SSL_ENABLE*                       | False                                               |
| *SSL_INSECURE*                     | True                                                |
| **TSN**                            |                                                     |
| TSN_AGENT_MODE                     | ""                                                  |
| TSN_AGENT_MODE                     | tsn-no-forwarding                                   |
| TSN_NODES                          | []                                                  |
| **vRouter**                        |                                                     |
| AGENT_MODE                         | kernel                                              |
| FABRIC_SNAT_HASH_TABLE_SIZE        | 4096                                                |
| PRIORITY_BANDWIDTH                 | ""                                                  |
| PRIORITY_ID                        | ""                                                  |
| PRIORITY_SCHEDULING                | ""                                                  |
| PRIORITY_TAGGING                   | True                                                |
| QOS_DEF_HW_QUEUE                   | False                                               |
| QOS_LOGICAL_QUEUES                 | ""                                                  |
| QOS_QUEUE_ID                       | ""                                                  |
| REQUIRED_KERNEL_VROUTER_ENCRYPTION | 4.4.0                                               |
| SAMPLE_DESTINATION                 | collector                                           |
| SLO_DESTINATION                    | collector                                           |
| VROUTER_COMPUTE_NODE_ADDRESS       |                                                     |
| VROUTER_CRYPT_INTERFACE            | crypt0                                              |
| VROUTER_DECRYPT_INTERFACE          | decrypt0                                            |
| VROUTER_DECRYPT_KEY                | 15                                                  |
| VROUTER_ENCRYPTION                 | TRUE                                                |
| VROUTER_GATEWAY                    |                                                     |
| **XMPP**                           |                                                     |
| SUBCLUSTER                         | ""                                                  |
| XMPP_SERVERS                       | $CONTROL_NODES with $XMPP_SERVER_PORT               |
| XMPP_SERVER_CA_CERTFILE            | $SERVER_CA_CERTFILE                                 |
| XMPP_SERVER_CERTFILE               | $SERVER_CERTFILE                                    |
| XMPP_SERVER_KEYFILE                | $SERVER_KEYFILE                                     |
| XMPP_SERVER_PORT                   | 5269                                                |
| XMPP_SSL_ENABLE                    | $SSL_ENABLE                                         |
