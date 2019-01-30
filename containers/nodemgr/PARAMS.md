# contrail-nodemgr parameters

| | default |
|---|---|
| **TF analytics** | |
| ANALYTICSDB_NODES | |
| ANALYTICS_NODES | |
| **Authentication** | |
| AUTH_MODE | |
| AUTH_PARAMS | |
| **BGP** | |
| BGP_ASN | |
| BGP_AUTO_MESH | |
| BGP_PORT | |
| **Cassandra** | |
| CASSANDRA_CQL_PORT | |
| CASSANDRA_JMX_LOCAL_PORT | |
| **Cloud orchestration** | |
| CLOUD_ORCHESTRATOR | |
| **TF collector** | |
| COLLECTOR_SERVERS | |
| **TF control** | |
| CONTROL_NODES | |
| **TF config** | |
| CONFIG_API_PORT | |
| CONFIG_NODES | |
| **Host** | |
| DEFAULT_HOSTNAME | |
| DIST_SNAT_PROTO_PORT_LIST | |
| ENCAP_PRIORITY | |
| FLOW_EXPORT_RATE | |
| **Keystone authentication** | |
| KEYSTONE_AUTH_ADMIN_PORT | |
| KEYSTONE_AUTH_CA_CERTFILE | |
| KEYSTONE_AUTH_CERTFILE | |
| KEYSTONE_AUTH_HOST | |
| KEYSTONE_AUTH_INSECURE | |
| KEYSTONE_AUTH_KEYFILE | |
| KEYSTONE_AUTH_PROJECT_DOMAIN_NAME | |
| KEYSTONE_AUTH_PROTO | |
| KEYSTONE_AUTH_URL_TOKENS | |
| **Logging** | |
| LOG_DIR | |
| LOG_LEVEL | |
| LOG_LOCAL | |
| **TF node manager** | |
| IPFABRIC_SERVICE_HOST | |
| IPFABRIC_SERVICE_PORT | |
| LINKLOCAL_SERVICE_IP | |
| LINKLOCAL_SERVICE_NAME | |
| LINKLOCAL_SERVICE_PORT | |
| NODEMGR_TYPE | |
| NODE_TYPE | |
| <NODE_TYPE>_NODES | |
| **Sandesh** | |
| INTROSPECT_SSL_ENABLE | |
| SANDESH_CA_CERTFILE | |
| SANDESH_CERTFILE | |
| SANDESH_KEYFILE | |
| SANDESH_SSL_ENABLE | |
| **vRouter** | |
| EXTERNAL_ROUTERS | |
| MAINTENANCE_MODE | |
| PROVISION_DELAY | |
| PROVISION_RETRIES | |
| VROUTER_GATEWAY | |
| VROUTER_HOSTNAME | |
| | |
| SUBCLUSTER | |

add_ini_params_from_env ${ntype}_NODEMGR /etc/contrail/$NODEMGR_NAME.conf
