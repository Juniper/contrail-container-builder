# contrail-provisioner parameters
Here documented only parameters user in provision.sh script now.

| parameters                        | default                                        |
| --------------------------------- | ---------------------------------------------- |
| **Authentication**                |                                                |
| AUTH_PARAMS                       | ''                                             |
| **BGP**                           |                                                |
| BGP_ASN                           | 64512                                          |
| BGP_AUTO_MESH                     | true                                           |
| BGP_PORT                          | 179                                            |
| ENABLE_4BYTE_AS                   | false                                          |
| **Cloud orchestration**           |                                                |
| CLOUD_ORCHESTRATOR                | none                                           |
| **Config**                        |                                                |
| CONFIGDB_NODES                    | $CONFIG_NODES                                  |
| CONFIG_API_PORT                   | 8082                                           |
| CONFIG_API_SSL_ENABLE             | $SSL_ENABLE                                    |
| *CONFIG_NODES*                    | $CONTROLLER_NODES                              |
| **Host**                          |                                                |
| DIST_SNAT_PROTO_PORT_LIST         | ""                                             |
| ENCAP_PRIORITY                    | MPLSoUDP,MPLSoGRE,VXLAN                        |
| FLOW_EXPORT_RATE                  | 0                                              |
| **Node manager**                  |                                                |
| <NODE_TYPE>_NODES                 |                                                |
| IPFABRIC_SERVICE_HOST             |                                                |
| IPFABRIC_SERVICE_PORT             | 8775                                           |
| LINKLOCAL_SERVICE_IP              | 169.254.169.254                                |
| LINKLOCAL_SERVICE_NAME            | metadata                                       |
| LINKLOCAL_SERVICE_PORT            | 80                                             |
| NODE_TYPE                         | name of the component                          |
| **vRouter**                       |                                                |
| EXTERNAL_ROUTERS                  | ""                                             |
| PROVISION_DELAY                   |                                                |
| PROVISION_RETRIES                 |                                                |
| SUBCLUSTER                        | ""                                             |
| **XMPP**                          |                                                |
| XMPP_SSL_ENABLE                   | $SSL_ENABLE                                    |


#TODO To be documented (These params are mentioned in the provision.sh file but not in the defaults table):
VXLAN_VN_ID_MODE
VROUTER_HOSTNAME
CONTROL_HOSTNAME
DEFAULT_HOSTNAME
TOR_TSN_IP
TOR_AGENT_NAME
TOR_NAME
TOR_VENDOR_NAME
TOR_IP
TOR_TUNNEL_IP
TOR_TSN_NAME
TOR_PRODUCT_NAME