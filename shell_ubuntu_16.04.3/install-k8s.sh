#!/bin/bash
#user root
set -x

export https_proxy=http://proxy.esl.cisco.com:8080
export ftp_proxy=http://proxy.esl.cisco.com:8080
#export no_proxy="localhost,127.0.0.1,.cisco.com,10.74.113.207,10.74.113.212"
export no_proxy=engci-maven.cisco.com

printf -v ip_68 '%s,' 10.74.68.{1..255}
printf -v ip_117 '%s,' 10.74.117.{1..255}
#172.19.216.114 maglav debootstrap server
export no_proxy="localhost,127.0.0.1,.cisco.com,172.19.216.114,${ip_68%,},${ip_117%,}"

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
