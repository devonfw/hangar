#!/bin/bash
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add jetstack https://charts.jetstack.io
helm repo add
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml
helm install cert-manager "jetstack/cert-manager" --namespace cert-manager --create-namespace --version v1.5.1
helm install rancher "rancher-latest/rancher" --namespace cattle-system --create-namespace --set hostname="$1" 