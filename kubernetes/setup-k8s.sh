#!/bin/bash

export OHOME=$HOME

linux=$(awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"')

sudo -u root /bin/bash << EOS

install_for_ubuntu () {
  service ufw stop
  iptables -F

  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list

  apt-get update -y
  apt-get install -y \
    docker.io \
    apt-transport-https \
    ca-certificates \
    kubectl kubelet kubeadm
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

  if [[ -f /etc/selinux/config && -n `grep "^[ ]*SELINUX[ ]*=" /etc/selinux/config` ]]; then
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
}

case "${linux}" in
  "ubuntu" )
    install_for_ubuntu
    ;;
  "centos" )
    install_for_centos
    ;;
esac

kubeadm init --kubernetes-version v1.7.4

mkdir -p $OHOME/.kube
cp -i /etc/kubernetes/admin.conf $OHOME/.kube/config
chown -R $(id -u):$(id -g) $OHOME/.kube

kubectl patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:8081/readiness"]}}}]' -n kube-system
kubectl patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/livenessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:10054/healthcheck/kubedns"]}}}]' -n kube-system && kubectl patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/1/livenessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:10054/healthcheck/dnsmasq"]}}}]' -n kube-system && kubectl patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/2/livenessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:10054/metrics"]}}}]' -n kube-system

EOS

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../parse-env.sh"
CONTRAIL_REGISTRY=$registry
source "$DIR/../containers/config-docker.sh"
