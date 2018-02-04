#!/bin/bash
set -x

#source proxy_bash

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
  kubeadm join --token ${KUBETOKEN} --discovery-token-unsafe-skip-ca-verification ${MASTER_IP}:6443
}

#./provision.sh master
cmd="$1"
shift
echo "$cmd $arg"
eval "$cmd" "$arg"
