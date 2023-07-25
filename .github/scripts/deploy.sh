#!/bin/bash

set -e

[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind create cluster
kind get clusters
kind load docker-image scarf-test:latest --name kind
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl apply -f site-deployment.yml
kubectl apply -f site-service.yml
sleep 10
kubectl get pods -n default
hello_world_pod_name=$(kubectl get pods -n default --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
kubectl exec -it -n default $hello_world_pod_name -- curl localhost:8080
kind delete cluster