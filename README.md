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
