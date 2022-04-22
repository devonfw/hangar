#!/bin/bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install nginx-ingress bitnami/nginx-ingress-controller --set ingressClassResource.default=true --namespace nginx-ingress --create-namespace --kubeconfig "$1"/kubeconfig