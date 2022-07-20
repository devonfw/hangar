#!/bin/bash
set -e
# Add image name, dns_name and tag.
# Source package-extra.sh to get ${tag}
. "$7"
export image="$2" tag="${tag}" dns="$3"
yq eval '.spec.template.spec.containers[0].image = "'"$image:$tag"'"' -i "$4"
yq eval '.spec.rules[0].host = "'"$dns"'"' -i "$5"
# Create namespace if not exists 
kubectl get namespace | grep -q "^$1" || kubectl create namespace "$1"
# Apply manifest files
kubectl apply -f "$6" --namespace="$1"
# Rollout deployments in the namespace
kubectl rollout restart deploy --namespace="$1"
