# Third-party docker containers

This folder contains third-party docker containers which are not provided as standard versions in docker hub or are customized for providing ability to work in a cluster setup.
After this abilitiy becomes avaulable in stock containers these containers could be removed.

There are 3 different ways to bring changes into the stock containers:

1. Own container for a 3-rd party component.
Container is built based on a stock one with own custom entrypoint script (contrail-entrypoint.sh) that makes required actions and re-calls stock entrypoint script (docker-entrypoint.sh). A container interface (env varitables) is kept as in stock one.
This way is an easiest one from the deployment orchestration point of view. A disavantage is a necessity to maintain own container, e.g. it is needed to host it somewhere and follow for updates of stock container to rebuild own one (e.g. if a security update released for stock containe).
    - Containers:
        ```
        contrail-container-builder/containers/external/rabbitmq
        contrail-container-builder/containers/external/zookeeper
        contrail-container-builder/containers/external/cassandra
        ```
    - An example of Kubernetes deployment configuration:
      ```
        contrail-container-builder/kubernetes/external/contrail-template.yaml
      ```

2. Init-container to a 3-rd party container
An init container brings the same as in #1 own custom entrypont script into the stock container via shared volume. This script should be used as entrypoint script for a stock container.
This way has no disavantage of maintaining own container but it is a bit more difficult to orchestrate, e.g. if dont use K8S or alike. Another disadvatage of this method is a necessity to have init-containers that are to be hosted somewhere, they inrease size required on disk and may increase a bit time to run (because one more container is neede to be pulled off, created and started).
    - Containers:
      ```
      contrail-container-builder/containers/external/rabbitmq-init
      contrail-container-builder/containers/external/zookeeper-init
      contrail-container-builder/containers/external/cassandra-init
      ```
    - An example of Kubernetes deployment configuration:
      ```
      contrail-container-builder/kubernetes/external/contrail-template-3p-init-container.yaml
      ```

3. Starter script for a 3-rd party container
It works for Kubernetes via ConfigMap: a custome sctipt is described in a ConfigMap that is mounted into stock container as a volume. This script should be used as entrypoint instead of stock one.
The script itself is the same as in #1 and #2.
This way has no additional containers. So, the only disadvantage is that it works via Kubernetes only for now and requries a bit more complicated orchestration than #1 (that is quite minor thing because K8S provides required orchestration).
    - An example of Kubernetes deployment configuration:
      ```
      contrail-container-builder/kubernetes/external/contrail-template-3p-starter-script.yaml
      ```
