#!/bin/bash
dnsName=$(kubectl get svc --namespace nginx-ingress nginx-ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
while test -z "$dnsName"
do
    sleep 5s
    dnsName=$(kubectl get svc --namespace nginx-ingress nginx-ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
done
echo "##vso[task.setvariable variable=dns;isOutput=true]$dnsName"