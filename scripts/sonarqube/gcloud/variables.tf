variable "service_account_file" {
  type = string
  description = "JSON file of a service account that can manage VMs"
}

variable "project" {
  type = string
  description = "The ID of the project in which the resource belongs"
}

variable "region" {
  type = string
  description = "The GCP region where the resources will be created"
}

variable "zone" {
  type = string
  description = "The zone inside the region that the machine should be created in"
}

variable "subnet_cidr_block" {
  type = string
  description = "The range of internal addresses that are owned by this subnetwork. Ranges must be unique and non-overlapping within a network"
}

variable "instance_type" {
  type = string
  description = "Machine Instance type"
}
