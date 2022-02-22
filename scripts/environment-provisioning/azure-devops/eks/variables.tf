variable "region" {
  type = string
  description = "The region where to provision resources"
}

variable "cluster_name" {
  type = string
  description = "AWS EKS Cluster Name"
}

variable "vpc_name" {
  type = string
  description = "Name for the VPC to be created"
}

variable "vpc_cidr_block" {
  type = string
  description = "Parameter for the virtual network IP-Range for creating a new VPC"
}

variable "private_subnets" {
  type = list(string)
  description = "Private subnet id range for creating VPC"
  default = ["none"]
}

variable "public_subnets" {
  type = list(string)
  description = "Public subnet id range for creating VPC"
  default = ["none"]
}

variable "instance_type" {
  type = string
  description = "[Optional] - Instance type of the worker node group configuration."
}

variable "existing_vpc_id" {
  type = string
  description = "[Optional] - Your available VPC ID as input to provision AWS EKS in it. Do not pass if not available."
  default = "none"
}

variable "existing_vpc_private_subnets" {
  type = list(string)
  description = "[Optional] - Your private subnet ids of available VPC. Do not pass if not available."
  default = ["none"]
}

