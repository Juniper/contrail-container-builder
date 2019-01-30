# contrail-kubernetes-cni-init parameters

| parameter                      | default                                        |
| ------------------------------ | ---------------------------------------------- |
| **Config**                     |                                                |
| *CONFIG_NODES*                 | $CONTROLLER_NODES                              |
| **Controller**                 |                                                |
| *CONTROLLER_NODES*             | $DEFAULT_LOCAL_IP                              |
| **Control**                    |                                                |
| CONTROL_NODES                  | $CONFIG_NODES                                  |
| **Host**                       |                                                |
| DEFAULT_IFACE                  | Default NIC                                    |
| PHYSICAL_INTERFACE             |                                                |
| VROUTER_GATEWAY                |                                                |
| *DEFAULT_LOCAL_IP*             | IP address of the NIC performs default routing |
| **Kubernetes**                 |                                                |
| KUBEMANAGER_NESTED_MODE        | 0                                              |
| KUBERNESTES_NESTED_VROUTER_VIP | 10.10.10.2                                     |
| **vRouter**                    |                                                |
| VROUTER_PORT                   | 9091                                           |
