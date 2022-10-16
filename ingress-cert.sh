#!/bin/bash
set -e

kubectl -n ingress-controller create secret tls default-wildcard --key builtin-ca/out/_.k8s.vagrant.local.key --cert builtin-ca/out/_.k8s.vagrant.local.crt

cat <<EOF >ingress-cm-patch.yaml
data: 
  ssl-certificate: ingress-controller/default-wildcard
EOF
kubectl -n ingress-controller patch cm haproxy-ingress --patch-file ingress-cm-patch.yaml

