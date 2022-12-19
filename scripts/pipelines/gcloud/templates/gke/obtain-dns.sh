#!/bin/false
(( i = 0 ))
while test -z "$clusterip"
do
  # We try during 5 minutes, if it does not work we rollback
  if (( "$i" == "60" ))
  then
    echo ""
    echo "ERROR: Unable to retrieve IP address of the ingress controller, destroying cluster..."
    echo ""
    echo ""
    terraform apply -destroy -auto-approve
    echo ""
    echo "Cluster destroyed after being unable to retrieve DNS name."
    exit 1
  fi
  sleep 5
  clusterip="$(kubectl get svc nginx-ingress-nginx-ingress-controller --namespace nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
  (( i++ ))
done
clusterhostname=$(nslookup "${clusterip}" | awk '/name = / {print $4}' | sed 's/.$//')