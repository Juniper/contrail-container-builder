# Third-party docker containers

This folder contains third-party docker containers which are not provided as standard versions in docker hub or are customized for providing ability to work in a cluster setup.
After this abilitiy becomes available in stock containers these containers could be removed.

There is a way to bring changes into the stock containers:

1. Overwritten custom container for a 3-rd party component.
Container is built based on a stock one with own custom entrypoint script (contrail-entrypoint.sh) that makes required actions and re-calls stock entrypoint script (docker-entrypoint.sh). A container interface (env variables) is kept as in stock one.
This way is an easiest one from the deployment orchestration point of view. A disavantage is a necessity to maintain your own container, e.g. it is needed to host it somewhere and follow for updates of stock container to rebuild own one (e.g. if a security update released for stock container).
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
