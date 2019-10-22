> Setup a Kubernetes learning environment, optimized in Mainland China (You know it :>).

This project helps you setup your own Kubernetes cluster, current running version is `v1.16`.


## Prerequisite
* [Virtuabox](https://www.virtualbox.org) 6.0.14
* [Vagrant](https://www.vagrantup.com/downloads.html) 2.2.6
* [Terraform](https://www.terraform.io) 0.12.12
* [Packer](https://packer.io) 1.4.4
* A host with 8+ GiB memory

## Build your own box with guest additions
```
cd iso
packer build centos7.json
```

If you have previously created the box, you should
```
# clear your terraform cache
rm -fr ~/.terraform/virtualbox/gold/virtualbox-centos7

# clear vagrant box if any
vagrant box remove centos7
```

## Choose either `Vagrant` or `terraform`

### With Vagrant
```
cd vagrant
vagrant up
```

### With Terraform
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
