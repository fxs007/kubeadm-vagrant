#!/bin/sh
set -x

export https_proxy=http://proxy.esl.cisco.com:8080
export ftp_proxy=http://proxy.esl.cisco.com:8080
#export no_proxy="localhost,127.0.0.1,.cisco.com,10.74.113.207,10.74.113.212"
export no_proxy=engci-maven.cisco.com

printf -v ip_68 '%s,' 10.74.68.{1..255}
printf -v ip_117 '%s,' 10.74.117.{1..255}
#172.19.216.114 maglav debootstrap server
export no_proxy="localhost,127.0.0.1,.cisco.com,172.19.216.114,${ip_68%,},${ip_117%,}"

POD_NW_CIDR="10.100.0.0/16"
#Bootstrap tokens 
KUBETOKEN="b029ee.968a33e8d8e6bb0d"
MASTER_IP="10.74.68.151"

master()
{
  kubeadm reset
  kubeadm init --apiserver-advertise-address=${MASTER_IP} --pod-network-cidr=${POD_NW_CIDR} --token ${KUBETOKEN} --token-ttl 0
  
  mkdir -p $HOME/.kube
  sudo cp -Rf /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
}

worker()
{
  kubeadm reset
  kubeadm join --token ${KUBETOKEN} ${MASTER_IP}:6443
}

#./provision.sh master
cmd="$1"
shift
echo "$cmd $arg"
eval "$cmd" "$arg"
