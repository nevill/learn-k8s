#!/bin/bash
sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
apt-get update
apt-get -y install \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg-agent \
	software-properties-common

curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
"deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu \
$(lsb_release -cs) \
stable"

curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add
echo "deb https://mirrors.ustc.edu.cn/kubernetes/apt kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

curl -s https://baltocdn.com/helm/signing.asc | sudo apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" > /etc/apt/sources.list.d/helm-stable-debian.list

apt-get update
apt-get install -y helm
apt-get install -y docker-ce docker-ce-cli containerd.io
apt-get install -y kubelet=1.20.11-00 kubeadm=1.20.11-00 kubectl=1.20.11-00
apt-mark hold kubelet kubeadm kubectl

adduser vagrant docker

mkdir /etc/docker
cat <<EOF | tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
