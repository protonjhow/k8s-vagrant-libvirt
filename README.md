# k8s-vagrant-libvirt

A minimal setup for running multi-node kubernetes in vagrant virtual
machines using libvirt on linux.

Related projects:

* https://github.com/galexrt/k8s-vagrant-multi-node (virtualbox, many features)

Current supported configuration(s):

* guest: rockylinux 8
* network: calico

# usage

Create and provision the cluster

```bash
vagrant up --provider=libvirt && vagrant ssh master
```

Test cluster access from your host

```
[~/src/k8s-vagrant-libvirt]$ kubectl get nodes
NAME      STATUS   ROLES    AGE   VERSION
master    Ready    master   30m   v1.25.2
worker0   Ready    <none>   30m   v1.25.2
```

# configuration

The following options may be set in the `Vagrantfile`

```ruby
# number of worker nodes
NUM_WORKERS = 2
# number of extra disks per worker
NUM_DISKS = 1
# size of each disk in gigabytes
DISK_GBS = 16
```

# troubleshooting

The following is a summary of the environments and applications that are known to work

```
[~/src/k8s-vagrant-libvirt]$ lsb_release -d
Description:    Pop!_OS 22.04 LTS

[~/src/k8s-vagrant-libvirt]$ vagrant version
Installed Version: 2.2.19

[~/src/k8s-vagrant-libvirt]$ vagrant plugin list
vagrant-libvirt (0.7.0, system)
```


-------
based on original work done here: https://github.com/dotnwat/k8s-vagrant-libvirt
