> Setup a Kubernetes learning environment, optimized in Mainland China (You know it :>).

## Prerequisite
* [Vagrant](https://www.vagrantup.com/downloads.html)
* [Virtuabox](https://www.virtualbox.org)
* A host with 8+ GiB memory

## Build your own box with guest additions
```
cd iso
packer build centos7.json

# clear your cache before using
rm -fr ~/.terraform/virtualbox/gold/virtualbox-centos7
vagrant box remove centos7
```

## Init a kubernetes cluster via
1. Vagrant
1. Terraform

with the help of kubeadm

### Vagrant
As simple as ```vagrant up```

### Terraform
```
cd terraform
terraform apply -target=null_resource.init_k8s_node
```

## Reference
1. https://kubernetes.io/docs/setup/independent/install-kubeadm/
1. https://github.com/CentOS/sig-cloud-instance-build/tree/master/vagrant
1. https://github.com/boxcutter/centos
1. https://github.com/geerlingguy/packer-centos-7
1. https://github.com/INSANEWORKS/centos-packer
