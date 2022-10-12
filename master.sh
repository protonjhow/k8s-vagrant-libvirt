#!/bin/bash
set -e

kubeadm config images pull
kubeadm init --pod-network-cidr=100.100.0.0/16 --token ${TOKEN}
KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f https://gist.githubusercontent.com/protonjhow/c5d887bb6f08af23999c58bdd9f05ceb/raw/6aedb09fff08733a0b2f59fa572d6c45663d2f7c/calico.yaml

mkdir /home/vagrant/.kube
chown vagrant /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant /home/vagrant/.kube/config
chmod 600 /home/vagrant/.kube/config
