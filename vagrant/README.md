> Setup a Kubernetes learning environment, especially in Mainland China (You know it).

## Prerequisite
* [Vagrant](https://www.vagrantup.com/downloads.html)
* [Virtuabox 5.1.30](https://www.virtualbox.org/wiki/Download_Old_Builds_5_1)
* A host have 2+ GiB free memory

## How to use it

1. Clone this repo
2. Following the steps
```bash
vagrant up
vagrant ssh
```
3. Create a pod and a service
```bash
]$ cd /vagrant/
]$ kubectl create -f nginx-pod.yml
pod "nginx" created
```
And then you will see
```
]$ kubectl get pod
NAME      READY     STATUS    RESTARTS   AGE
nginx     1/1       Running   0          32s
```
Yeah! Congratulations for your first running POD!

### Manually setup

1. Prepare a CentOS 7 virtual machine, it requires 2 GiB memory at least.
2. Install kubernets by ```yum install -y etcd kubenertes```
3. Edit fowllowing files
```
# /etc/kubernetes/apiserver
KUBE_API_ADDRESS="--insecure-bind-address=127.0.0.1"
KUBE_ETCD_SERVERS="--etcd-servers=http://127.0.0.1:2379"
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"
KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota"

# /etc/sysconfig/docker
OPTIONS='--selinux-enabled=false --log-driver=journald --signature-verification=false'
if [ -z "${DOCKER_CERT_PATH}" ]; then
    DOCKER_CERT_PATH=/etc/docker
fi

# /etc/kubernets/kubelet
KUBELET_ADDRESS="--address=127.0.0.1"
KUBELET_HOSTNAME="--hostname-override=127.0.0.1"
KUBELET_API_SERVER="--api-servers=http://127.0.0.1:8080"
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.docker-cn.com/google/pause:latest"
KUBELET_ARGS=""

# /etc/docker/daemon.json
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
```

4. Remove some weird useless files
```
rm -fr /etc/docker/certs.d/
```

5. Install and start service
```
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start kube-proxy
systemctl start kubelet
```

Copy the spec file nginx-pod.yml to your VM
```
kubectl create -f nginx-pod.yml
kubectl get pod
```
