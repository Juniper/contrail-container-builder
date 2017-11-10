# Deploying Contrail with Helm OpenStack

For the background info  please refer to README
The following guide is a working sequence for building and running Contrail with Helm OpenStack in Amazon. In order to run it in some other environment, please skip the unrelated-sections and do the necessary actions appropriately.
Two VMs are used here: build-VM and deployment-VM.

## Prepare Machines
 
Prepare two machines. One for build process - 8Gb ram, 2 cores, 60Gb disk (m4.large in amazon). Second for run openstack-helm gating - 32Gb ram, 16 cores, 60Gb disk (c4.4xlarge in amazon).

## Prepare VPC

Use default VPC (make sure the ports are open - see below) or configure a new one:
* Create VPC: 
```
   aws ec2 create-vpc --cidr-block 192.168.130.0/24
```
* Get created VPC ID and create subnet: 
```
   aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 192.168.130.0/24
```
* Create Internet Gateway: 
```
   aws ec2 create-internet-gateway
```
* Get created Internet Gateway ID and attach it: 
```
   aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
```
* Get route table ID: 
```
   aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC_ID
```
* Create route: 
```
   aws ec2 create-route --route-table-id $RTB_ID --destination-cidr-block "0.0.0.0/0" --gateway-id $IGW_ID
```
* Open ports 22, 5000, 8143 in default security group of created vpc

## Run instances
* Create key pair to access instances and save printed private part to file my_key: 
```
   aws ec2 create-key-pair --key-name my_key
```
* Find appropriate image id (for region us-west-2 is ami-82bd4ffa)
* Get subnet id from previous step
* Run instance for build: 
```
   aws ec2 run-instances --image-id ami-82bd4ffa --key-name  --instance-type m4.large --subnet-id $SUBNET_ID --associate-public-ip-address --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":60,"DeleteOnTermination":true}}]')
```
* Run instance for helm: 
```
   aws ec2 run-instances --image-id ami-82bd4ffa --key-name  --instance-type c4.4xlarge --subnet-id $SUBNET_ID --associate-public-ip-address --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":60,"DeleteOnTermination":true}}]')
```
* Wait for instances and save public IPs of them

## Build containers

* Go to build machine:
```
   ssh -i ./my_key ec2-user@$BUILD_IP
```
* Set version: 
```
   export CONTRAIL_VERSION=4.0.2.0-35
```
* Install utilities: 
```
   sudo yum install -y git wget ntp iproute
```
* Clone build repo: 
```
   git clone https://github.com/Juniper/contrail-container-builder
```
* Run build:
```
   cd docker-contrail-4/containers
   ./setup-for-build.sh
   sudo -E ./build.sh
```
* After build without error you can find several containers: 
```
   sudo docker images | grep "$CONTRAIL_VERSION"
```

## Run Helm

* Go to machine for OpenStack Helm: 
```
   ssh -i ./my_key ec2-user@$HELM_IP
   set version: export CONTRAIL_VERSION=4.0.2.0-35
   set IP of machine where build was run: export REGISTRY_IP=$BUILD_IP
```
* allow docker use own repository - create file /etc/docker/daemon.json with content: 
```
   {
       "insecure-registries": ["$REGISTRY_IP:5000"]
   }
```
* Helm deploys Ceph for storage and CentOS requires adding the repo as stated on ceph site. Create /etc/yum.repos.d/ceph.repo with content:
```
   [ceph]
   name=Ceph packages for x86_64
   baseurl=https://download.ceph.com/rpm/el7/x86_64
   enabled=1
   priority=2
   gpgcheck=1
   gpgkey=https://download.ceph.com/keys/release.asc

   [ceph-noarch]
   name=Ceph noarch packages
   baseurl=https://download.ceph.com/rpm/el7/noarch
   enabled=1
   priority=2
   gpgcheck=1
   gpgkey=https://download.ceph.com/keys/release.asc

   [ceph-source]
   name=Ceph source packages
   baseurl=https://download.ceph.com/rpm/el7/SRPMS
   enabled=0
   priority=2
   gpgcheck=1
   gpgkey=https://download.ceph.com/keys/release.asc
```
* Install utilities: 
```
   sudo yum install -y git wget ntp
```
* To avoid problem with loading vrouter.ko in the middle of deployment process (cannot allocate memory) we recommend to insert kernel module before running Helm:
```
   wget -nv http://$REGISTRY_IP/$CONTRAIL_VERSION/vrouter.ko
   chmod 755 vrouter.ko
   sudo insmod ./vrouter.ko
```
* Clone openstack-helm with new changes for microservices: 
```
   git clone https://github.com/openstack/openstack-helm
```
* Change directory to it: 
```
   cd openstack-helm
```
* Containers/Charts development are not finished yet so you need to change registry IP where containers are stored:
```
   for fn in `grep -r -l "localhost:5000" *`; do sed "s/localhost:5000/${REGISTRY_IP}:5000/g" < "$fn" > result; rm "$fn"; mv result "$fn"; done
```
* Run helm’s gating:
```
   export INTEGRATION=aio
   export INTEGRATION_TYPE=basic
   export SDN_PLUGIN=opencontrail
   ./tools/gate/setup_gate.sh
```
* The gate script should install kubernetes/helm/openstack/contrail and some tests for OpenStack. Create network/subnet and run VM. Due to unknown problems with simple gateway VM is not accessible by floating IP.
