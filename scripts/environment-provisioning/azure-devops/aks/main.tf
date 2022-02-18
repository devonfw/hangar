terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
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

    default_node_pool {
        name = "default"
        node_count = var.agent_count
        vm_size = var.instance_type
    }

    network_profile {
        load_balancer_sku = "Standard"
        network_plugin = "kubenet"
    }

    role_based_access_control {
        enabled = true
    }

    identity {
        type = "SystemAssigned"
    }
}