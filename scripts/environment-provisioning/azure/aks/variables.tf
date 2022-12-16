variable "cluster_name" {
    description = "Name for the AKS cluster"
    type = string
}

variable "location" {
    description = "Location where to provision resources"
    type = string
}

variable "resource_group_name" {
    description = "Name for the resource group" 
    type = string
}

variable "instance_type" {
    description = "Type of instance used"
    type = string
}

variable "worker_node_count" {
    description = "Number of worker nodes for the cluster"
    type = string
}

variable "dns_prefix" {
    description = "DNS name prefix to use with the hosted Kubernetes API server FQDN. This forms part of the fully qualified domain name used to access the cluster"
    type = string
}