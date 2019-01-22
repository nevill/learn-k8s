> Setup a Kubernetes learning environment, optimized in Mainland China (You know it :>).

Init a kubernetes cluster via
1. Ansible
1. Terraform

## Terraform

In this way, we are using kubeadm to init our cluster.

### building iso
```
cd terraform/iso
packer build centos7.json

# clear your cache before using
rm -fr ~/.terraform/virtualbox/gold/virtualbox-centos7
```

## Reference
1. https://kubernetes.io/docs/setup/independent/install-kubeadm/
1. https://github.com/CentOS/sig-cloud-instance-build/tree/master/vagrant
1. https://github.com/boxcutter/centos
1. https://github.com/geerlingguy/packer-centos-7
1. https://github.com/INSANEWORKS/centos-packer
