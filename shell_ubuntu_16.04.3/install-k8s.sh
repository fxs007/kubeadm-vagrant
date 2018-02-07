#!/bin/bash
#user root
set -x

source proxy_bash

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt install -y apt-transport-https
apt-get update
apt-get install -y docker.io kubelet kubeadm kubectl kubernetes-cni

#exit

systemctl enable kubelet && systemctl start kubelet
systemctl enable docker && systemctl start docker

CGROUP_DRIVER=$(sudo docker info | grep "Cgroup Driver" | awk '{print $3}')

sed -i "s|KUBELET_KUBECONFIG_ARGS=|KUBELET_KUBECONFIG_ARGS=--cgroup-driver=$CGROUP_DRIVER |g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

#change cluster-dns
sed -i 's/10.96.0.10/10.100.0.10/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload

systemctl stop kubelet && systemctl start kubelet

#xinsheng steps
swapoff -a
#update hosts file
#update proxy in docker
#for i in $(cat docker_images); do docker pull $i;done

