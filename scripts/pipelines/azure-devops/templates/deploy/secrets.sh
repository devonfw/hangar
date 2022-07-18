#!/bin/bash
set -e
# Deploy apps in exists namespace, If not exists Create new namespace.
kubectl get namespace | grep -q "^$1" || kubectl create namespace "$1"
# Command to existed secrets and create new secrets to pull image from private registry.
kubectl delete secret "$2" --namespace="$1" --ignore-not-found 
kubectl create secret docker-registry "$2" --docker-server="$5" --docker-username="$3" --docker-password="$4" --namespace="$1"
export secrets="$2" 
yq e '.spec.template.spec."imagePullSecrets"=[{"name":"secrets"}]' -i "$6" 
yq e '.spec.template.spec.imagePullSecrets[0].name = "'"$secrets"'"' -i "$6"
# Apply the changes.
kubectl apply -f "$6" --namespace="$1"