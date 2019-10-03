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

function ver() {
  printf "%02d%02d%02d%02d" ${1//./ }
}

sudo -u root /bin/bash << EOS

function disable_swap() {
  echo disable swap
  # todo: uncomment the unmount of tmpfs in case of swapoff hangs
  #umount -a -t tmpfs
  swapoff -a
  sed -i.bak '/^[^#].*[ \t]\+swap[ \t]\+/ s/\(.*\)/#\1/g' /etc/fstab
}

function install_for_ubuntu() {
  service ufw stop || echo 'WARNING: failed to stop firewall service'
  systemctl disable ufw || echo 'WARNING: failed to disable firewall'

  iptables -F || echo 'WARNING: failed to flush iptables rules'
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT

  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list

  apt-get update -y &>>$HOME/apt.log
  k8s_version="${K8S_VERSION}-00"
  apt-get install -y \
    docker.io ntp \
    apt-transport-https \
    ca-certificates \
    kubectl=\$k8s_version kubelet=\$k8s_version kubeadm=\$k8s_version &>>$HOME/apt.log

  kubelet_cfg_file='/etc/systemd/system/kubelet.service.d/10-kubeadm.conf'
}

function install_for_centos() {
  service firewalld stop || echo 'WARNING: failed to stop firewall service'
  chkconfig firewalld off || echo 'WARNING: failed to disable firewall'
  iptables -F || echo 'WARNING: failed to flush iptables rules'
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT

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
    sed -i 's/^[ ]*SELINUX[ ]*=.*/SELINUX=permissive/g' /etc/selinux/config
  else
    echo "SELINUX=permissive" >> /etc/selinux/config
  fi

  k8s_version="${K8S_VERSION}-0"
  pkgs_to_install="kubelet-\$k8s_version kubeadm-\$k8s_version kubectl-\$k8s_version ntp"
  if ! docker --version 2>&1 ; then
    pkgs_to_install+=' docker'
  fi
  yum install -y \$pkgs_to_install
  systemctl enable docker && systemctl start docker
  systemctl enable kubelet && systemctl start kubelet
  systemctl enable ntpd.service && systemctl start ntpd.service

  sysctl -w net.bridge.bridge-nf-call-iptables=1
  sysctl -w net.bridge.bridge-nf-call-ip6tables=1
  echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
  echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.conf

  if [[ $(ver $K8S_VERSION) -ge $(ver 1.11.2) && $(ver $K8S_VERSION) -lt $(ver 1.12) ]] || \
     [[ $(ver $K8S_VERSION) -ge $(ver 1.12.7) && $(ver $K8S_VERSION) -lt $(ver 1.13) ]] || \
     [[ $(ver $K8S_VERSION) -ge $(ver 1.13.5) ]]; then
    kubelet_cfg_file="/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf"
  else
    kubelet_cfg_file="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
  fi
}

disable_swap

case "${LINUX_ID}" in
  "ubuntu" )
    install_for_ubuntu
    ;;
  "centos" | "rhel" )
    install_for_centos
    ;;
esac

need_kubelet_restart='false'

# Contrail, at this point in time, does not install CNI/vrouter-agent on nodes marked as control.
# In a typcical Kubernetes install, kubelets expects to find CNI plugin in nodes they are running.
# When it does not find it, the corresponding node is flagged as not ready.
# Our recommendation is to start kubelet with CNI not-enabled.
if [[ ! ,$AGENT_NODES, == *,$HOST_IP,* ]]; then
  echo "INFO: Node $HOST_IP is not an agent - disable CNI on it."
  sed -i "s|^\(.*KUBELET_NETWORK_ARGS=.*\)$|#\1|" "\$kubelet_cfg_file"
  need_kubelet_restart='true'
fi

docker_cgroup=\$(docker info | awk '/Cgroup Driver:/ {print(\$3)}')
if [[ -n "\$docker_cgroup" ]] ; then
  echo "INFO: Change kubelet cgroups to \$docker_cgroup"
  sed -i "s/--cgroup-driver=[[:alnum:]]*/--cgroup-driver=\$docker_cgroup/g" "\$kubelet_cfg_file"
  need_kubelet_restart='true'
fi

if [[ "\$need_kubelet_restart" == 'true' ]] ; then
  echo "INFO: restart kubelet service"
  systemctl daemon-reload
  systemctl restart kubelet.service
fi

EOS

# assignment doesn't work under sudo
kube_ver="v$(kubectl version --short=true 2>/dev/null | sed 's/.* v//')"
join_flags='--discovery-token-unsafe-skip-ca-verification'

api_srv_opts=''
if [[ -n "$KUBERNETES_API_SERVER" ]] ; then
  api_srv_opts="--apiserver-advertise-address $KUBERNETES_API_SERVER"
fi

sudo -u root /bin/bash << EOS
# cloud-init of oficial AWS CentOS image at first boot dynamically changes hostname to short name while static name is full one.
# This leads to the node register itself with the short name and cannot register after rebooting with full name.
# Here we try to set hostname to static name if they differ.
if [[ -n "$hostname" && "$hostname" != `hostname` ]]; then
  hostname $hostname
fi

if [[ -z "$join_token" ]]; then
  echo "INFO: kubectl version is $kube_ver"
  kubeadm init $api_srv_opts --kubernetes-version $kube_ver

  mkdir -p $HOME/.kube
  cp -u /etc/kubernetes/admin.conf $HOME/.kube/config
  chown -R $(id -u):$(id -g) $HOME/.kube
else
  if [[ -z "$KUBERNETES_API_SERVER" ]]; then
    echo ERROR: Kubernetes master node IP is not specified in KUBERNETES_API_SERVER
    exit -1
  fi
  echo Join to $KUBERNETES_API_SERVER:6443
  kubeadm join $join_flags --token $join_token $KUBERNETES_API_SERVER:6443
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
