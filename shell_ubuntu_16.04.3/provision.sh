#!/bin/bash
set -x

source proxy_bash

POD_NW_CIDR="10.100.0.0/16"
#Bootstrap tokens 
KUBETOKEN="b029ee.968a33e8d8e6bb0d"
MASTER_IP="10.74.68.151"

master_new()
{
  #kubeadm init --apiserver-advertise-address=${MASTER_IP} --pod-network-cidr=${POD_NW_CIDR} --token ${KUBETOKEN} --token-ttl 0
  kubeadm init --config ./kubeadm.conf_master1
  
  mkdir -p $HOME/.kube
  sudo cp -Rf /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
}

master_join()
{
  #etcd cluster
  curl http://10.74.68.151:2379/v2/members
  curl -X POST -H "Content-Type: application/json" -d '
{"peerURLs": ["http://10.74.68.153:2380"]}
'  http://10.74.68.151:2379/v2/members

  kubeadm init --config kubeadm.conf_master2
  
  mkdir -p $HOME/.kube
  sudo cp -Rf /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

}

worker()
{
  #kubeadm join --token b029ee.968a33e8d8e6bb0d 10.74.68.151:6443 --discovery-token-ca-cert-hash sha256:e5b86401e844f766347f8cc336763b37ac83317f65a1327f0728ef981f403d36
  kubeadm join --token ${KUBETOKEN} --discovery-token-unsafe-skip-ca-verification ${MASTER_IP}:6443
}

reset()
{
  kubeadm reset
  ifconfig cni0 down
  ip link delete cni0
  ifconfig flannel.1 down
  ip link delete flannel.1
  rm -rf /var/lib/cni/
}

#./provision.sh master_new
cmd="$1"
shift
echo "$cmd $arg"
eval "$cmd" "$arg"
