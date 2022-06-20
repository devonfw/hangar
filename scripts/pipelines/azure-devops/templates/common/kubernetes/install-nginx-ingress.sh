#!/bin/bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install nginx-ingress bitnami/nginx-ingress-controller --set ingressClassResource.default=true --set containerSecurityContext.allowPrivilegeEscalation=false --namespace nginx-ingress --create-namespace