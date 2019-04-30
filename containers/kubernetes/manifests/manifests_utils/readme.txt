Commands to get all scripts and manifests in working directory:
Required parameters in common.env file: PHYSICAL_INTERFACE, HOST_IP, KUBE_MANIFEST

WORKING_DIR=/contrail-container-builder/contrail_yaml
KUBE_MANIFESTS_IMAGE=192.168.30.157:5000/contrail-kubernetes-manifests:queens-5.1.0-553
mkdir $WORKING_DIR
cp common.env $WORKING_DIR
docker run -d --rm -v $WORKING_DIR:/manifests_temp --env-file common.env $KUBE_MANIFESTS_IMAGE

commands to install contrail:
cd $WORKING_DIR
sudo ./set-node-labels.sh
sudo kubectl apply -f contrail.yaml
sudo kubectl -n=kube-system get pods