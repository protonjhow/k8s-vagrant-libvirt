#!/bin/bash
set -e

echo "dropping a bunch of fun scripts to play with in ~/playground. Have fun!"
mkdir /home/vagrant/playground

echo "echoserver.yaml is a simple service that parrots back anything you request towards it."
echo "deploy it like this: "
echo "  kubectl create -f playground/echoserver.yaml"
echo "test it like so: "
echo "  curl -k -H 'Host: echoserver.local' https://100.99.9.201      # or whatever your ingress IP is!"
cat <<EOF > /home/vagrant/playground/echoserver.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: echoserver
  name: echoserver
  namespace: default
spec:
  selector:
    matchLabels:
      app: echoserver
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: echoserver
    spec:
      containers:
      - image: k8s.gcr.io/echoserver:1.3
        imagePullPolicy: IfNotPresent
        name: echoserver
        resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: echoserver
  name: echoserver
  namespace: default
spec:
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: echoserver
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: haproxy
  name: echoserver
  namespace: default
spec:
  rules:
  - host: echoserver.local
    http:
      paths:
      - backend:
          service:
            name: echoserver
            port:
              number: 8080
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echoserver.local
EOF


# before we go, make sure vagrant user owns all the stuff in the folder
chown -R vagrant:vagrant /home/vagrant/playground

