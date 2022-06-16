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
  description = "Instance type for cluster workers."

}
variable "desired_workers" {
  type = string
  description = "Cluster Node Group Desired Capacity"
}
variable "max_workers" {
  type = string
  description = "Cluster Node Group Maximum Capacity"
}
variable "min_workers" {
  type = string
  description = "Cluster Node Group Minimum Capacity"
}

variable "existing_vpc_id" {
  type = string
  description = "[Optional] - Your existing VPC ID as input to provision AWS EKS in it."
  default = "none"
}

variable "existing_vpc_private_subnets" {
  type = list(string)
  description = "[Optional] - Your existing private subnet ids."
  default = ["none"]
}

