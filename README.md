# Contrail containers based on microservices

This is a version of Contrail containers based on microservices.
Checked on:
  - Kubernetes with CNI
  - Docker compose (via contrail-ansible-deployer)
  - OpenStack Helm

Works with limitations and known issues.

Everything is tested in CentOS 7.4 / Ubuntu 16.04 for deployment to run on one/three machines.

## Building containers

* Get Ubuntu 16 or Centos 7 with internet connection
* Install additional packages if needed (e.g. `git` and `curl`).
* Get the project sources (e.g. with ```git clone```)
* Configure ```common.env``` (copy ```common.env.sample``` for that and configure minimal set of parameters. Verify that CONTRAIL_INSTALL_PACKAGES_URL is configured.)
* Run ```cd containers```
* Run ```./setup-for-build.sh```
* Add any number of `*.repo.template` (for CentOS) or `*.list.template` (for Ubuntu) to the root of repo. These files will be evaluated with current environment and will be placed to containers to yum or apt configuration.
* Run ```sudo ./build.sh```

If you have a problems with resolving DNS names in build process then you to fix your docker like this - https://development.robinwinslow.uk/2016/06/23/fix-docker-networking-dns/

You'll get Docker registry running locally on port 5000 with the containers built.

You can check them here: http://localhost:5000/v2/_catalog or ```sudo docker images```

## Provisioning Kubernetes

Use this section if you want to deploy Contrail with Kubernetes without Helm

**ATTENTION**: Kubernetes version 1.12 is not supported now. Use versions 1.11 and earlier.

* Run on a single or master-node ```kubernetes/setup-k8s.sh``` (don't forget to ```cd ../``` if you're in ```containers```)

For multi-node deployment on other kubernetes nodes:

* Set KUBERNETES_API_SERVER and CONTRAIL_REGISTRY in environment or in ```common.env```
* Run ```kubernetes/setup-k8s.sh join-token=<token>``` where token can be taken from output of **setup-k8s.sh** on master node or from ```sudo kubeadm token list```

## Provisioning Contrail and CNI in Kubernetes without Helm on a single node

* Configure ```common.env``` if it's not done previously (copy ```common.env.sample``` for that)
* Run ```cd kubernetes/manifests```
* Create deployment yaml like this:

  ``` ./resolve-manifest.sh contrail-standalone-kubernetes.yaml > contrail.yaml```
* Run ```./set-node-labels.sh``` to allow kubernetes to apply labels according to ```common.env```.
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

## Sandbox

You can try to create the sandbox with Contrail here: https://tungstenfabric.github.io/website/Tungsten-Fabric-15-minute-deployment-with-k8s-on-AWS.html

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
```sudo docker ps | grep contrail | awk '{print($1)}' | xargs sudo docker restart```~~
