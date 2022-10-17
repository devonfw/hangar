#!/bin/bash
set -e
# Create namespace if not exists 
kubectl get namespace | grep -q "^$1" || kubectl create namespace "$1"
# Fill imagePullSecrets
export secrets="$2" 
yq e '.spec.template.spec."imagePullSecrets"=[{"name":"secrets"}]' -i "$6" 
yq e '.spec.template.spec.imagePullSecrets[0].name = "'"$secrets"'"' -i "$6"
# Apply the changes.
# Create imagePullSecret if not exists
kubectl create secret docker-registry "$2" --docker-server="$5" --docker-username="$3" --docker-password="$4" --namespace="$1" --save-config --dry-run=client -o yaml | kubectl apply -f - --namespace="$1"