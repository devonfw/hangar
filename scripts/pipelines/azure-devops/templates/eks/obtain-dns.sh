dnsName=$(kubectl get svc --namespace nginx-ingress nginx-ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
while test -z "$dnsName"
do
    sleep 5s
    dnsName=$(kubectl get svc --namespace nginx-ingress nginx-ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
done
clustername=$1
az pipelines variable-group create --organization $(System.TeamFoundationCollectionUri) --project "$(System.TeamProject)" --name eks_variables --variable dns_name=$dnsName cluster_name=$clustername --authorize true
echo "##vso[task.setvariable variable=dns;isOutput=true]$dnsName"