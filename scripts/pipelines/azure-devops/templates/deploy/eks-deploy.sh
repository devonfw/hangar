#!/bin/bash
set -e
# Add image name and ingress DNS name.
export image="$2" dns="$3"
yq eval '.spec.template.spec.containers[0].image = "'"$image"'"' -i "$4"
yq eval '.spec.rules[0].host = "'"$dns"'"' -i "$5"
# Create namespace in EKS cluster.
kubectl create namespace "$1"
# Apply manifest files.
kubectl apply -f "$6" --namespace="$1"