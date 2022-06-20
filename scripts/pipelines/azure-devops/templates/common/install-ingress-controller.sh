#!/bin/bash
helm repo add bitnami "https://charts.bitnami.com/bitnami"
helm repo update
helm upgrade --install nginx-ingress "nginx-ingress-controller" --set ingressClassResource.default=true --set containerSecurityContext.allowPrivilegeEscalation=false --repo "https://charts.bitnami.com/bitnami" --namespace nginx-ingress --create-namespace