# Kubernetes manifests

This directory hosts a series of templates that allow installation of Contrail
on an existing Kubernetes cluster, using single yaml mode of installation.
Each template caters to a specific deployment model of Contrail.
These templates can be used to generate a single yaml file, that can inturn be
used provision Contrail on a Kubernetes cluster.

# Provision

Provisioning of Contrail on Kubernetes cluster is a 3 step process:

Step 1. Clone this repository

Step 2. Populate common.env file in the top directory of this repo.

        Some samples are made available in <repo-dir>/kubernetes/sample_config_files for
        standard deployment scenarios.

Step 3. Install Contrail
```
       cd <repo-dir>/kubernetes/manifests

       ./resolve-manifest.sh <template-file> | kubectl apply -f -
```

# Templates

The following is the brief description of each of those templates.
You should choose the right template for your desired Contrail deployement model.

* contrail-standalone-kubernetes.yaml

To deploy standalone and all-in-one Contrail cluster. All Contrail components will be deployed.

* contrail-dpdk-standalone-kubernetes.yaml

To deploy standalone and all-in-one Contrail cluster with DPDK for forwarding.
All Contrail components will be deployed.

* contrail-nested-kubernetes.yaml

To deploy Contrail in a Nested deployment mode. This model is intended for scenarios where
Contrail is providing networking function for an Openstack cluster and user would like to
provision a Kubernetes cluster on Virtual Machines spawned on this Openstack cluster.

In this model, only contrail control plane agent (i.e Contrail Kube-Manager) and data plane
agent (i.e Contrail CNI) will be deployed in the overlay Kubernetes cluster.
These agents will in-turn interface with Contrail Control and Data plane processes
managing networking in the underlay Openstack cluster.

* contrail-non-nested-kubernetes.yaml

To deploy Contrail in a non-nested non-standalone deployment model. In this mode, the Contrail control
plane agent (i.e Contrail Kube-Manager) will be delployed to interface with Kubernetes control plane.
For the data plane, this mode will install data plane agent(i.e Contrail CNI), data plane control
module(contrail vrouter agent) and data plane forwarding module(contrail vrouter kernel module).

These deployed components will interface with Contrail Control and Data plane processes that have been
independently installed someplace else and are reachable by ip routing.


* reference-templates/contrail-template.yaml

A reference template file, capturing all possible and relevant config environments for Kubernetes
deployment. This is strictly for reference and is not intended for yaml file generation.

# FAQ

* How can I generate yaml file to provision Contrail cluster with images from private docker registry ?

Step 1. In your Kubernetes cluster, create a kubernetes secret with credentials of the private docker registry.

```
kubectl create secret docker-registry <name> --docker-server=<registry> --docker-username=<username> --docker-password=<password> --docker-email=<email> -n <namespace>

<name>      - name of the secret
<registry>  - example: hub.juniper.net/contrail
<username>  - registry user name
<password>  - registry passcode
<email>     - registered email of this registry account
<namespace> - kubernetes namespace where this secret is to be created. This should be the namespace where you intend to create pods.

```

Step 2. Generate single yaml file after setting variable KUBERNETES_SECRET_CONTRAIL_REPO=<secret-name> in common.env file

```
File: $SBOX/common.env

...
KUBERNETES_SECRET_CONTRAIL_REPO=<secret-name>
...

<secret-name>  - Name of the secret created in Step 1.
```

