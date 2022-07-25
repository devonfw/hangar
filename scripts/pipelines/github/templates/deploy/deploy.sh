#!/bin/bash
set -e
# Add image name, dns_name and tag.
# Run package-extra.sh to ${tag}
. "$7"
# we get what is located after the last '/' in the branch name, so it removes /ref/head or /ref/head/<folder> if your branche is named correctly"
branch_short=$(echo "$8" | awk -F '/' '{ print $NF }')

# We change the name of the tag depending if it is a release or another branch
echo "tag_completed: $8" | grep release && tag_completed="${tag}"
echo "tag_completed_branch: $8" | grep release || tag_completed="${tag}_${branch_short}"

export image="$2" tag_completed="${tag_completed}" dns="$3"
yq eval '.spec.template.spec.containers[0].image = "'"$image:$tag_completed"'"' -i "$4"
yq eval '.spec.rules[0].host = "'"$dns"'"' -i "$5"
# Deploy apps in exists namespace, If not exists Create new namespace and apply manifest files.
kubectl get namespace | grep -q "^$1" || kubectl create namespace "$1"
kubectl apply -f "$6" --namespace="$1"
