> Setup a Kubernetes learning environment, optimized in Mainland China (You know it :>).

This project helps you setup your own Kubernetes cluster, current running version is `v1.20`.

## Prerequisite
* [Virtuabox](https://www.virtualbox.org) 6.1.26
* [Vagrant](https://www.vagrantup.com/downloads.html) 2.2.18
* [Packer](https://packer.io) 1.7.6
* A host with 24+ GiB memory (for 3 hosts setup)

## Build your own box

1. Execute the command to build the box.

```sh
packer build .
```

2. Import to your vagrant box list.

```
vagrant box add --name basek8s box/package.box
```

## Use the box created above

1. Create a new host network in Virtualbox.

From menu item File -> Host Network Manager, create a new adapter named `vboxnet1`, assign IPv4 address `192.168.34.1` and network mask `255.255.255.0` to it.

This network will be used by cluster nodes.

2. Start the VMs.

```sh
vagrant up
```

When VMs are up, initialize the Kubernetes cluster via `kubeadm`, and make sure it has the correct node IP set.


```sh
vagrant ssh primary

# make sure the network is working.
ping -c 2 192.168.34.3
ping -c 2 192.168.34.4

sudo kubeadm init --config kubeadm-init.yaml

# copy KUBECONFIG to $HOME/.kube/config as the output of previous step noted.

kubectl get no -o wide

# make sure the node internal-ip is 192.168.34.2 here,
# but the node status is NotReady.

NAME      STATUS     ROLES                  AGE   VERSION    INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
primary   NotReady   control-plane,master   75s   v1.20.11   192.168.34.2   <none>        Ubuntu 20.04.3 LTS   5.4.0-88-generic   docker://20.10.9
```

3. Install a CNI plugin, here we choose [cilium](https://cilium.io).
```sh
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.10.4 --namespace kube-system

# wait for a while depending on your network, when it's successfully setup, the primary node should become to Ready.

kubectl get no -o wide

NAME      STATUS     ROLES                  AGE     VERSION    INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
primary   Ready   control-plane,master   5m29s   v1.20.11   192.168.34.2   <none>        Ubuntu 20.04.3 LTS   5.4.0-88-generic   docker://20.10.9
```

4. On other 2 nodes, run `kubeadmin join` to join the cluster.

```sh
kubectl get no -o wide

NAME      STATUS   ROLES                  AGE     VERSION    INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
node02    Ready    <none>                 6m27s   v1.20.11   192.168.34.3   <none>        Ubuntu 20.04.3 LTS   5.4.0-88-generic   docker://20.10.9
node03    Ready    <none>                 5m6s    v1.20.11   192.168.34.4   <none>        Ubuntu 20.04.3 LTS   5.4.0-88-generic   docker://20.10.9
primary   Ready    control-plane,master   22m     v1.20.11   192.168.34.2   <none>        Ubuntu 20.04.3 LTS   5.4.0-88-generic   docker://20.10.9

```

## Reference

1. https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
1. https://www.packer.io/docs/builders/vagrant
1. https://www.vagrantup.com/docs/providers/virtualbox/networking
1. https://github.com/easzlab/kubeasz
1. https://www.tkng.io
