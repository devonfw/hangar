#!/bin/bash
################################ Description ############################################
# This script is used to build and push an image to a container registry
################################# Arguments #############################################
# -h : hostname of the ingress controller to setup the different ingress object correctly
#########################################################################################
set -e

while getopts h: flag
do
    case "${flag}" in
        h) hostname=${OPTARG};;
        *) echo "Error: Unexpected flag." >&2
            exit 1;;
    esac
done

# Init vars
scriptDir="$(dirname "$0")"
fileToModify="prometheus-ingress.yaml grafana-ingress.yaml alertmanager-ingress.yaml"

# Create namespace and object for the default namespace
set +e
kubectl create -f "${scriptDir}/setup"
set -e

# Modify the ingress.yaml to fit with the host of the Ingress controller
for i in $fileToModify
do
  sed "s/example.com/$hostname/g" -i "${scriptDir}/${i}"
done

# Apply all the yaml to deploy the monitoring tools
kubectl apply -f "${scriptDir}"

# Installing Loki
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki --namespace=monitoring grafana/loki-stack
