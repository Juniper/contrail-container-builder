# Contrail containers based on microservices

This is an alfa version of Contrail containers based on microservices. Checked on Kubernetes with CNI and in OpenStack Helm. Works with limitations and known issues.
Everything is tested in CentOS 7.4 for deployment to run on one machine.

## Building containers

* Get Ubuntu 16 or Centos 7 with internet connection
* Get the project sources (e.g. with ```git clone```)
* Run ```cd containers```
* Configure ```common.env``` (copy ```common.env.sample``` for that)
* Run ```setup-for-build.sh```
* Run ```sudo build.sh```

You'll get Docker registry running locally on port 5000 with the containers built. 
You can check them here: ```http://localhost:5000/v2/_catalog```

## Provisioning Kubernetes

Use this section if you want to deploy Contrail with Kubernetes without Helm

* Run ```kubernetes/setup-k8s.sh```

## Provisioning Contrail and CNI in Kubernetes without Helm

* Configure ```common.env``` if it's not done previously (copy ```common.env.sample``` for that)
* Create deployment yaml like this: 
  ```kubernetes/manifests/resolve-manifest.sh < contrail-micro.yaml.template > contrail-micro.yaml```
* Deploy Contrail:
  ```kubectl apply -f kubernetes/manifests/contrail-micro.yaml```
* Check the deployment by:
  ```kubectl -n=kube-system get pods```
  
You'll have Contrail deployed in Kubernetes. Check WebUI in https://localhost:8143 (login:admin password:contrail123)
This deployment will work with noauth authentication.

## Provisioning Contrail in Helm OpenStack

Please refer to the README-HELM.md

## Known issues

* "No route to host" error during container build
** The reason: firewall
** To fix: Stop the firewalld or ```add iptables -I INPUT -j ACCEPT; iptables -I OUTPUT -j ACCEPT```
* "Connection refused" error during container build when accessing repodata/repomd.xml
** The reason: lighthttpd doesn't work properly
** To fix: bring up some other httpd server and allow visibility for the repo
* vrouter container in agent pod can fail when loading kernel module with "cannot allocate memory". 
** The reason - large driver memory appetites and probably significant memory fragmentation.
** Can be remedied by rebooting the machine and in the worst case inserting the vrouter module manually right after the reboot.
* kube-dns and any application containers (if you run some later) can be stuck in "Container creating" state. 
** The reason - Supposed race condition during start-up with Contrail DB. Will be fixed later
** Can be remedied by manually restarting all contrail-* and kube-manager containers. Probably by restarting their pods (haven't tried yet). Restarting can be done by: 
```docker ps | grep contrail | awk '{print($1)}' | xargs docker restart```

## TODOs

1. Refactoring - base and common split to specific modules
2. NodeManager - eliminate all, leave just one
3. Neutron, nova - revisit pluginization mechanism
4. Kubeagent - create new one
5. All scripts - move to root dir
6. Source rpm repo in setup, add parameter to take from non-S3
+7. Rename contrail-micro.yaml to contrail-micro.yaml.sample
+8. Create README
9. Remove firewall during setup
10. Deal with “cannot allocate memory” during kernel module loading
11. Complete vrouter container - add DPDK, VLAN, etc.
12. Create initContainer for vrouter compilation
13. Split charts to Contrail-only and the rest
14. Remove all notions about OpenStack/Keystone/Kubernetes from Contrail containers and add separate containers (sidecars) bringing orchestrator-related functionality.
15. Ubuntu version
16. Nested cni.conf (if needed)
17. /var/crashes folder should be created (mounted in host)
18. Unnecessary packages should be removed from containers
19. Make DEBUG logging configurable
20. Multi-node deployment
21. Cluster-deployment for Contrail, Cassandra, etc (Helm POC chart has problem for Cassandra config)
22. Rework Helm charts to reuse third-party charts instead of built-in sections
23. Add yum clean at the end of containers
24. Rename kubernetes/kube-agent to kubernetes/vrouter-init
25. Move kube-manager to kubernetes folder
26. Add synchronization for containers (supposedly Cassandra and Zookeeper for controller should be run before contrail containers)
27. Remove contrail-config section from yaml and remove all its remaining usages

