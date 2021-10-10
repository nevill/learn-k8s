> Setup a Kubernetes learning environment, optimized in Mainland China (You know it :>).

This project helps you setup your own Kubernetes cluster, current running version is `v1.22`.

## Prerequisite
* [Virtuabox](https://www.virtualbox.org) 6.1.26
* [Vagrant](https://www.vagrantup.com/downloads.html) 2.2.18
* [Packer](https://packer.io) 1.7.6
* A host with 16+ GiB memory (for 3 hosts setup)

## Build your own box
```
cd box
packer build basek8s.hcl
```

## Import to vagrant box list
```
vagrant box add --name basek8s box/packer.box
```

## Reference
1. https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
