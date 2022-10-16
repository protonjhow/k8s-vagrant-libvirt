#!/bin/bash
set -e

kubeadm join ${MASTER_IP}:6443 --token ${TOKEN} --discovery-token-unsafe-skip-ca-verification

MY_IP=$(hostname -I | sed -rn 's/.*\s(100\.99\.9\.[0-9]{3}).*/\1/p' -)
echo $MY_IP
echo "KUBELET_EXTRA_ARGS='--node-ip ${MY_IP}'" > /etc/sysconfig/kubelet

systemctl restart kubelet.service

