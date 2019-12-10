
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
* Add any number of `*.repo.template` (for CentOS) to the root of repo. These files will be evaluated with current environment and will be placed to containers to yum configuration.
* Run ```sudo ./build.sh```
* To use custom images instead of DockerHub images - set appropriate environment variables before build. For example:
* export LINUX_DISTR=gcr.io/cloud-marketplace-containers/google/centos7
* export LINUX_DISTR_VER=latest
* export UBUNTU_DISTR=gcr.io/cloud-marketplace-containers/google/ubuntu1604
* export UBUNTU_DISTR_VERSION=latest

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

## For developers

### Structure of the repository

This repo consists of the following:

* containers
  - The containers grouped by functionality with some containers serving as base layers for other "endpoint" Contrail containers
  - build scripts
* kubernetes
  - Manifests and config files serving for evaluation of containers on kubernetes without usage of any upper level orchestrators/products like ansible/JuJu/RHOSP/etc
* samples and templates
  - common.env.sample and contrail.repo.template - files used to store configuration parameters and description of the contrail repo with RPMs to be used during build


### Container

Containers here should comply with microservice-based architecture (https://en.wikipedia.org/wiki/Microservices). It means running a single process App inside each container.
Containers are based mostly on "base" (contrail-specific) or "general-base" (generic) containers. They, in turn, are based on CentOS image (except for several Ubuntu-specific ones)

A container usually consists of the following:
* dockerfile
  - installs everything during build process, defines the command to run a process
* entrypoint.sh (or similar name)
  - startup script for each container invoked from dockerfile and handling incoming env parameters
* other scripts and files (if applicable)
* PARAMS.md
  - list of environment parameters (see [README-PARAMS.md](README-PARAMS.md) for details)

### Tools

Tools are located in "containers" directory
They consist of:
* build.sh and setup-for-build.sh
  - main build scripts, usage described in section "Building containers"
* helper scripts
  - invoked from main ones to do particular action

### K8S manifests

Kubernetes directory contains manifests which allow to deploy various layouts of Contrail with Kubernetes.
They use corresponding config files stored in sample_config_files.
There is also a helper script setup-k8s.sh which allows setting up kubernetes.
Each manifest is a template which can be resolved by script ./manifests/resolve-manifest.sh. Also scripts apply.sh and delete.sh can be used to deploy or delete Contrail with automatic resolution of the template. There is a separate readme (https://github.com/Juniper/contrail-container-builder/tree/master/kubernetes/manifests) describing this in more details.

Manifests are designed in a way prescribing kubernetes to lay out Contrail roles according to labels specified in the manifest.

Examples of deployment are described in sections in the beginning.

These manifests are also stored and published in a container "contrail-k8s-manifests". You can generate deployment yamls using this container:
* Download contrail image "contrail-k8s-manifests" container from a registry of your choice (TF, Juniper, DockerHub, etc) with `docker pull`.
* Create docker container
``` docker create --name k8s-manifests tungstenfabric/contrail-k8s-manifests```
* Copy content from container to local folder
``` docker cp k8s-manifests:contrail-container-builder .```
* Remove container
``` docker rm -fv k8s-manifests```
* Check list of manifests in folder contrail-container-builder/kubernetes/manifests/
* Create required common.env in folder contrail-container-builder
* Prepare manifest with simple manifests (or use your own one)
``` contrail-container-builder/kubernetes/manifests/resolve-manifest.sh contrail-standalone-kubernetes.yaml > contrail.yaml```
* Additionally you can use contrail-container-builder for any development or viewing purposes.

### Adding new container

Before adding new container, please fill in a blueprint (https://blueprints.launchpad.net/opencontrail/+specs?show=all) and spec (https://github.com/Juniper/contrail-specs) stating why and how you're planning to do this.
As a general rule, use existing containers as samples.

To implement new container the following can be done:
* Create a directory for the new container
  - Place it in the corresponding or a new group directory, for example, analytics-related containers can be placed to "analytics" directory
* Implement dockerfile
  - Derive your container FROM one of the base images: base image in your group directory (analytics/base, for example), main Contrail base or general-base for non-Contrail-specific containers
* Add parameters to containers/base/common.sh (to corresponding group or a new one) and to common.env.sample (if applicable)
* Implement entrypoint.sh
  - Take env parameters and fill local configs with them (if applicable) or use them in any other way - see other containers as samples (containers/controller/config/api/entrypoint.sh, for example)
  - Use utility functions for Contrail-related containers (like add_ini_params_from_env, set_third_party_auth_config, set_vnc_api_lib_ini) if required
* If you're implementing third-party software container (like new etcd)
  - Add it to "external" directory in a manner done by other external containers there
* Consider implementing init_container if you need one-time action at the beginning (like vrouter/kernel-init), use "-init" postfix for the name
* Update kubernetes manifests and configs to deploy your new container
* Define new nodemgr type (see containers/nodemgr/entrypoint.sh) if you're adding a new pod and add your pod with your container and new nodemgr container into manifests
* Write PARAMS.md


While adding new container DO NOT break the microservices paradigm - don't try to start more than one process inside one container. Don't overcomplicate it: if you need it to run other service then most probably you need to create more than one container. Pass parameters through env variables only.

Ask for advice if you still have questions (see contacts at the end)

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

## Contacts

Please use Tungsten Fabric Slack for posting your questions: https://tungstenfabric.slack.com/messages/C0DQ4JPCZ/details/
