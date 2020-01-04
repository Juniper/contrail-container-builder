# contrail-kubernetes-cni-init parameters

| parameter                      | default                                        |
| ------------------------------ | ---------------------------------------------- |
| **Config**                     |                                                |
| *CONFIG_NODES*                 | $CONTROLLER_NODES                              |
| **Controller**                 |                                                |
| *CONTROLLER_NODES*             | IP address of the NIC performs default routing |
| **Control**                    |                                                |
| CONTROL_NODES                  | $CONFIG_NODES                                  |
| **Host**                       |                                                |
| PHYSICAL_INTERFACE             |                                                |
| VROUTER_GATEWAY                |                                                |
| **Kubernetes**                 |                                                |
| KUBEMANAGER_NESTED_MODE        | 0                                              |
| KUBERNESTES_NESTED_VROUTER_VIP | 10.10.10.2                                     |
| **vRouter**                    |                                                |
| VROUTER_PORT                   | 9091                                           |
