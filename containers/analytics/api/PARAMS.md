# contrail-analytics-api parameters

| | default |
|---|---|
| **Authentication** | |
| AAA_MODE | |
| **TF analytics** | |
| ANALYTICSDB_CQL_SERVERS | |
| ANALYTICS_API_INTROSPECT_LISTEN_PORT | |
| ANALYTICS_API_INTROSPECT_PORT | |
| ANALYTICS_API_LISTEN_IP | |
| ANALYTICS_NODES | |
| ANALYTICS_UVE_PARTITIONS | |
| **TF collector** | |
| COLLECTOR_SERVERS | |
| **TF config** | |
| CONFIG_SERVERS | |
| **Logging** | |
| LOG_DIR | |
| LOG_LEVEL | |
| LOG_LOCAL | |
| **Redis** | |
| REDIS_SERVERS | |
| REDIS_SERVER_PASSWORD | |
| REDIS_SERVER_PORT | |
| **Sandesh** | |
| INTROSPECT_SSL_ENABLE | |
| SANDESH_CA_CERTFILE | |
| SANDESH_CERTFILE | |
| SANDESH_KEYFILE | |
| SANDESH_SSL_ENABLE | |
| **Zookeeper** | |
| ZOOKEEPER_ANALYTICS_SERVERS_SPACE_DELIM | |

add_ini_params_from_env ANALYTICS_API /etc/contrail/contrail-analytics-api.conf
