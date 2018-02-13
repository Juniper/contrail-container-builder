# Contrail containers based on microservices

This is an beta version of Contrail containers based on microservices.
Checked on:
  - Kubernetes with CNI
  - Docker compose (via contrail-ansible-deployer)
  - OpenStack Helm
Works with limitations and known issues.
Everything is tested in CentOS 7.4 / Ubuntu 16.04 for deployment to run on one/three machines.

## Building containers

* Get Ubuntu 16 or Centos 7 with internet connection
* Get the project sources (e.g. with ```git clone```)
* Run ```cd containers```
* Configure ```common.env``` (copy ```common.env.sample``` for that and configure minimal set of parameters)
* Run ```setup-for-build.sh```
* Add any number of *.repo.template (for CentOS) or *.list.template (for Ubuntu) to the root of repo. These files will be evaluated with current environment and will be placed to containers to yum or apt configuration.
* Run ```sudo build.sh```

If you have a problems with resolving DNS names in build process then you to fix your docker like this - https://development.robinwinslow.uk/2016/06/23/fix-docker-networking-dns/

You'll get Docker registry running locally on port 5000 with the containers built.
You can check them here: ```http://localhost:5000/v2/_catalog``` or ```sudo docker images```

## Provisioning Kubernetes

Use this section if you want to deploy Contrail with Kubernetes without Helm

* Run on a single or master-node ```kubernetes/setup-k8s.sh``` (don't forget to ```cd ../``` if you're in ```containers```)

For multi-node deployment on other kubernetes nodes:

* Set KUBERNETES_API_SERVER and CONTRAIL_REGISTRY in environment or in ```common.env```
* Run ```kubernetes/setup-k8s.sh join-token=<token>``` where token can be taken from output of setup-k8s.sh on master node or from ```sudo kubeadm token list```

## Provisioning Contrail and CNI in Kubernetes without Helm on a single node

* Configure ```common.env``` if it's not done previously (copy ```common.env.sample``` for that)
* Create deployment yaml like this:
  ```
  cd kubernetes/manifests
  ./resolve-manifest.sh contrail-template.yaml > contrail.yaml
  ```
* Deploy Contrail:
  ```kubectl apply -f contrail.yaml```
* Check the deployment by:
  ```kubectl -n=kube-system get pods```

You'll have Contrail deployed in Kubernetes. Check WebUI in https://localhost:8143 (login:admin password:contrail123)
This deployment will work with noauth authentication.

You can use ```apply.sh``` and ```delete.sh``` helper scripts from ```kubernetes/manifests``` to apply and delete kubernetes deployments without manually using ```resolve-manifest.sh``` and ```kubectl apply```.

## Multi-node deployment

* Configure ```common.env``` to contain lists of nodes for your deployment for CONTROLLER_NODES, AGENT_NODES, etc before Contrail deployment
* Run ```kubernetes/manifest/set-node-labels.sh``` to allow kubernetes to apply labels according to ```common.env```.
* Deploy Contrail on master kubernetes node as decribed in "Provisioning Contrail and CNI in Kubernetes without Helm on a single node"

## Multi-card deployment

* Configure ```common.env``` PHYSICAL_INTERFACE, VROUTER_GATEWAY and KUBERNETES_NODES_MAP parameters before Contrail deployment.

## Provisioning Contrail in Helm OpenStack

Please refer to the README-HELM.md

## Known issues

* "No route to host" or cannot access mirrors.centos.org errors during container build
  - The reason: firewall
  - To fix: Allow connectivity like ```add iptables -I INPUT -j ACCEPT```
* "Connection refused" error during container build when accessing repodata/repomd.xml
  - The reason: lighthttpd doesn't work properly
  - To fix: bring up some other httpd server and allow visibility for the repo
* vrouter container in agent pod can fail when loading kernel module with "cannot allocate memory".
  - The reason: large driver memory appetites and probably significant memory fragmentation.
  - To fix: reboot the machine and in the worst case insert the vrouter module manually right after the reboot.!~
* (Fixed). kube-dns and any application containers (if you run some later) can be stuck in "Container creating" state.
  - The reason: Supposed race condition during start-up with Contrail DB. Will be fixed later
  - To fix: manually restart all contrail-* and kube-manager containers. Probably by restart their pods (haven't tried yet).    Restarting can be done by:
```docker ps | grep contrail | awk '{print($1)}' | xargs docker restart```~~

## TODOs

1. Refactoring - base and common split to specific modules
2. ~~NodeManager - eliminate all, leave just one~~
3. ~~Neutron, nova, heat - revisit pluginization mechanism~~
4. ~~Kubeagent - create new one~~
5. All scripts - move to root dir
6. ~~Source rpm repo in setup, add parameter to take from non-S3~~
7. ~~Rename contrail-micro.yaml to contrail-micro.yaml.sample~~
8. ~~Create README~~
9. ~~Remove firewall during setup~~
10. Deal with “cannot allocate memory” during kernel module loading
11. **Complete vrouter container - add DPDK, VLAN, etc.**
12. ~~Create initContainer for vrouter compilation~~
13. Split charts to Contrail-only and the rest
14. Remove all notions about OpenStack/Keystone/Kubernetes from Contrail containers and add separate containers (sidecars) bringing orchestrator-related functionality.
15. ~~Kernel module compilation for Ubuntu~~
16. Nested cni.conf (if needed)
17. ~~/var/crashes folder should be created~~
18. ~~Unnecessary packages should be removed from containers~~
19. ~~Make DEBUG logging configurable~~
20. ~~**Multi-node deployment**~~
21. ~~**Cluster-deployment for Contrail, Cassandra, etc**~~
22. Rework Helm charts to reuse third-party charts instead of built-in sections
23. ~~Add yum clean at the end of containers~~
24. ~~Rename kubernetes/kube-agent to kubernetes/vrouter-init~~
25. ~~Move kube-manager to kubernetes folder~~
26. ~~Add synchronization for containers (supposedly Cassandra and Zookeeper for controller should be run before contrail containers)~~
27. ~~Remove contrail-config section from yaml and remove all its remaining usages~~
28. Add comments to each entrypoint.sh for interface ENV variables
29. ~~Rework configuration passing in charts~~
30. ~~Improve provisioning scripts to work with existing docker repo and other features~~
31. Nodemgr - rework to use single conf and no env variables (everything is taken from conf)
32. Nodemgr - fix known bugs
33. Nodemgr - package correctly into rpm, now docker takes it by git clone
34. Optimize size
35. Make CNI plugin log level configurable.
36. ~~Sort out with multiple NIC configiration - probably provision link local is needed since it set ip_fabric_ip.~~
37. Consider to use K8S services to provide VIPs for Config, Analytics and WebUI.
38. Split common.env to separate build.env and deployment.env
39. Add switching off dhcp on phys_int after inserting vhost0
40. Standardize configuration variables across all components in the system.
41. ~~Add provision-alarm.py (https://bugs.launchpad.net/juniperopenstack/+bug/1736279)~~
42. ~~Avoid changing /etc/hosts file (rabbitmq).~~
43. ~~vrouter agent entrypoint: add ability to configure metadata_proxy_secret=contrail in [METADATA]~~
44. Sort out with KUBERNETES_public_fip_pool
45. ~~Ubuntu containers~~
46. Introduce base container for agent and move agent specific functions to it
