variable "aws_region" {
  type = string
  description = "location of the aws infrastructure deployment"
}

variable "vpc_cidr_block" {
  type = string
  description = "define your vpc cidr block"
}

variable "subnet_cidr_block" {
  type = string
  description = "define your subnet cidr block"
}
variable "nic_private_ip" {
    type = string
    description = "the private ip needs to be within the subnet cidr range "
}

variable "instance_type" {
  type = string
  description = "instance_type"
}

variable "key_name" {
  type = string
  description = "Name of the key"
}
