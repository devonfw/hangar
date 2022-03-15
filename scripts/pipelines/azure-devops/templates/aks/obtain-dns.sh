#!/bin/bash
ip=$(kubectl get -o json svc nginx-stable-nginx-ingress --namespace nginx-ingress --kubeconfig $1/kubeconfig | python -c "import sys, json; print(json.load(sys.stdin)['status']['loadBalancer']['ingress'][0]['ip'])")

url=$2
length=${#url}
dnsname=${url:22:length-22-1}

ipname=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$ip')].[name]" --output tsv)

iprg=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$ip')].[resourceGroup]" --output tsv)

az network public-ip update --resource-group $iprg --name $ipname --dns-name $dnsname

dns=$(az network public-ip show --resource-group $iprg --name $ipname --query "[dnsSettings.fqdn]" --output tsv)

echo "##vso[task.setvariable variable=dns;]$dns"