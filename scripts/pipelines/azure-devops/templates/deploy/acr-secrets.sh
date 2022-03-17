#!/bin/bash

#Command to create secrets to pull image from private registry.
kubectl delete secret $(secretsValue) --namespace=$(k8sNamespace) --kubeconfig $(Pipeline.Workspace)/kubeconfig/kubeconfig
# create secrets for private registry.
kubectl create secret docker-registry $(secretsValue) \
    --docker-server=$(registry) \
    --docker-username=$(docker_username) \
    --docker-password=$(docker_password) \
    --namespace=$(k8sNamespace) \
    --kubeconfig $(Pipeline.Workspace)/kubeconfig/kubeconfig 
# export secrets name and add secrets into deployment file.
export secrets=$(secretsValue) 
yq e '.spec.template.spec."imagePullSecrets"=[{"name":"secrets"}]' -i $(Build.Repository.LocalPath)/$(deployFiles)/*-deployment.yaml 
yq e '.spec.template.spec.imagePullSecrets[0].name = "'$secrets'"' -i $(Build.Repository.LocalPath)/$(deployFiles)/*-deployment.yaml 
# Apply the changes.
kubectl apply -f $(Build.Repository.LocalPath)/$(deployFiles)/*-deployment.yaml --namespace=$(k8sNamespace) --kubeconfig $(Pipeline.Workspace)/kubeconfig/kubeconfig