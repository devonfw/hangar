#!/bin/bash
set -e
# Add image name and ingress DNS name.
export image="$1" dns="$2"
yq eval '.spec.template.spec.containers[0].image = "'$image'"' -i "$3" 
yq eval '.spec.rules[0].host = "'$dns'"' -i "$4"
# Create namespace in AKS cluster.
kubectl create namespace "$6" --kubeconfig "$7"
# Apply manifest files.
kubectl apply -f "$5" --namespace="$6" --kubeconfig "$7"