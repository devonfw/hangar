#!/bin/bash
ip="$(kubectl get svc nginx-ingress-nginx-ingress-controller --namespace nginx-ingress --kubeconfig $1/kubeconfig -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

while test -z "$ip"
do
    sleep 5s
    ip="$(kubectl get svc nginx-ingress-nginx-ingress-controller --namespace nginx-ingress --kubeconfig $1/kubeconfig -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
done

url=$2
length=${#url}
# Obtain the organization name by taking away the first 22 characters (https://dev.azure.com/) and the last /.
dnsname=${url:22:length-22-1}

ipname=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$ip')].[name]" --output tsv)

iprg=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$ip')].[resourceGroup]" --output tsv)

az network public-ip update --resource-group "$iprg" --name "$ipname" --dns-name "$dnsname"

dns="$(az network public-ip show --resource-group $iprg --name $ipname --query "[dnsSettings.fqdn]" --output tsv)"

echo "##vso[task.setvariable variable=dns;]$dns"
