#!/bin/bash
# Sets up kubernetes on a node. Parameters are taken from common.env.
# Can be used in a multi-node deployment. For all non-master kubernetes nodes this could be run:
# setup-k8s.sh join-token=<token>
# Token can be found in output from setup-k8s.sh run on master node or from "sudo kubeadm token list"
# For multi-node setup on non-master kubernetes nodes common.env should contain CONTRAIL_REGISTRY and KUBERNETES_API_SERVER
# configured.
# Parameters:
# join-token: used on non-master nodes
# develop: used for development on master node, automatically pull new images during each container run

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../parse-env.sh"

nocasematch=`shopt | grep nocasematch | awk '{print $2}'`
shopt -s nocasematch
for key in "$@"; do
  case $key in
    develop)
      develop_mode=true
    ;;
    join-token=*)
      join_token="${key#*=}"
    ;;
    *)
      echo ERROR: Unknown option $key
      exit
    ;;
  esac
done
if [[ $nocasematch == "off" ]]; then
  shopt -u nocasematch
fi

hostname=`cat /etc/hostname`

sudo -u root /bin/bash << EOS

kube_ver=''

install_for_ubuntu () {
  service ufw stop
  iptables -F

  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
  # for latest kubernetes latest docer is needed
  #curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  #add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  apt-get update -y &>>$HOME/apt.log
  apt-get install -y \
    docker.io \
    apt-transport-https \
    ca-certificates \
    kubectl kubelet kubeadm &>>$HOME/apt.log
  kube_ver="v$(kubectl version --short=true 2>/dev/null | sed 's/.* v//')"
}

install_for_centos () {
  service firewalld stop
  iptables -F

  cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
     https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

  setenforce 0 || true

  if [ -f /etc/selinux/config ] && grep "^[ ]*SELINUX[ ]*=" /etc/selinux/config ; then
    sed -i 's/^[ ]*SELINUX[ ]*=/SELINUX=permissive/g' /etc/selinux/config
  else
    echo "SELINUX=permissive" >> /etc/selinux/config
  fi

  yum install -y kubelet-1.7.4-0 kubeadm-1.7.4-0 kubectl-1.7.4-0 docker
  systemctl enable docker && systemctl start docker
  systemctl enable kubelet && systemctl start kubelet

  sysctl -w net.bridge.bridge-nf-call-iptables=1
  sysctl -w net.bridge.bridge-nf-call-ip6tables=1
  echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
  echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.conf
  kube_ver='1.7.4'
}

case "${LINUX_ID}" in
  "ubuntu" )
    install_for_ubuntu
    ;;
  "centos" | "rhel" )
    install_for_centos
    ;;
esac

# cloud-init of oficial AWS CentOS image at first boot dynamically changes hostname to short name while static name is full one.
# This leads to the node register itself with the short name and cannot register after rebooting with full name.
# Here we try to set hostname to static name if they differ.
if [[ -n "$hostname" && "$hostname" != `hostname` ]]; then
  hostname $hostname
fi

if [[ -z "$join_token" ]]; then
  kubeadm init --kubernetes-version $kube_ver

  mkdir -p $HOME/.kube
  cp -u /etc/kubernetes/admin.conf $HOME/.kube/config
  chown -R $(id -u):$(id -g) $HOME/.kube
else
  if [[ -z "$KUBERNETES_API_SERVER" ]]; then
    echo ERROR: Kubernetes master node IP is not specified in KUBERNETES_API_SERVER
  fi
  echo Join to $KUBERNETES_API_SERVER:6443
  kubeadm join --token $join_token $KUBERNETES_API_SERVER:6443
fi

EOS

if [[ -z "$join_token" ]]; then
  kubectl patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:8081/readiness"]}}}]' -n kube-system
  kubectl patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/livenessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:10054/healthcheck/kubedns"]}}}]' -n kube-system && kubectl patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/1/livenessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:10054/healthcheck/dnsmasq"]}}}]' -n kube-system && kubectl patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/2/livenessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:10054/metrics"]}}}]' -n kube-system

  # Changing apiserver manifest results to restart apiserver, so we do this at the end to avoid waiting of apiserver is ready for other operations (e.g. kubectl patch)
  if [[ -n "$develop_mode" ]]; then
    sudo grep "admission-control=.*AlwaysPullImages" /etc/kubernetes/manifests/kube-apiserver.yaml > /dev/null
    r=$?
    if (( $r == 1 )); then
      echo Enable AlwaysPullImages control plug-in
      sudo sed -i 's/- --admission-control=.*/&,AlwaysPullImages/' /etc/kubernetes/manifests/kube-apiserver.yaml
    fi
  fi
fi

source "$DIR/../containers/config-docker.sh"
