date > /etc/vagrant_box_build_time

mount -o loop /home/vagrant/VBoxGuestAdditions.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -f /home/vagrant/VBoxGuestAdditions.iso

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --disable docker-ce-*
yum-config-manager --enable docker-ce-stable
yum makecache
yum install -y docker-ce-18.06.1.ce
usermod -aG docker vagrant
systemctl enable docker

cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

systemctl start docker
kubeadm config --kubernetes-version 1.13.2 images pull

# ref https://github.com/box-cutter/centos-vm/
rm -rf /tmp/*
yum -y clean all

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

sync
