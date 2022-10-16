#!/bin/bash
set -e

kubeadm config images pull
kubeadm init --pod-network-cidr=100.100.0.0/16 --token ${TOKEN} --apiserver-advertise-address=${MASTER_IP}
KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f https://gist.githubusercontent.com/protonjhow/c5d887bb6f08af23999c58bdd9f05ceb/raw/6aedb09fff08733a0b2f59fa572d6c45663d2f7c/calico.yaml

echo "KUBELET_EXTRA_ARGS='--node-ip ${MASTER_IP}'" > /etc/sysconfig/kubelet
systemctl restart kubelet.service

mkdir /home/vagrant/.kube
chown vagrant /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant /home/vagrant/.kube/config
chmod 600 /home/vagrant/.kube/config
echo "source <(kubectl completion bash)" >> ~/.bashrc 

curl --output /tmp/helm-v3.10.1-linux-amd64.tar.gz https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
tar -zxvf /tmp/helm-v3.10.1-linux-amd64.tar.gz -C /tmp linux-amd64/helm
sudo mv /tmp/linux-amd64/helm /usr/local/bin

helm repo add haproxy-ingress https://haproxy-ingress.github.io/charts
helm repo update
mkdir /opt/helm/

cat <<EOF > /opt/helm/haproxy-ingress-values.yaml
---
controller:
  hostNetwork: true
EOF

helm template haproxy-ingress haproxy-ingress/haproxy-ingress --namespace ingress-controller --version 0.13.9 -f /opt/helm/haproxy-ingress-values.yaml > /opt/helm/haproxy-ingress-manifest.yaml
kubectl create namespace ingress-controller
kubectl apply -f /opt/helm/haproxy-ingress-manifest.yaml
