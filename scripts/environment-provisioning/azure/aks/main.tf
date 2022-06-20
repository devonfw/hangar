terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "3.0.2"
        }
    }

    backend "azurerm" {}
}

provider "azurerm" {
    features {}
}

resource "azurerm_kubernetes_cluster" "cluster" {
    name = var.cluster_name
    location = var.location
    resource_group_name = var.resource_group_name
    dns_prefix = var.dns_prefix
    role_based_access_control_enabled = true

    default_node_pool {
        name = "default"
        node_count = var.worker_node_count
        vm_size = var.instance_type
    }

    network_profile {
        load_balancer_sku = "standard"
        network_plugin = "kubenet"
    }

    identity {
        type = "SystemAssigned"
    }
}