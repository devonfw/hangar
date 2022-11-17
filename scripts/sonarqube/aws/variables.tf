variable "region" {
  type = string
  description = "AWS region code of the location where the resources will be created"
}

variable "vpc_cidr_block" {
  type = string
  description = "Virtual private network IP range (CIDR)"
}

variable "subnet_cidr_block" {
  type = string
  description = "Subnetwork IP range (CIDR) within VPC"
}
variable "nic_private_ip" {
    type = string
    description = "Instance private IP within subnet range"
}

variable "instance_type" {
  type = string
  description = "EC2 Instance type"
}

variable "keypair_name" {
  type = string
  description = "Keypair name as defined in AWS"
}

variable "sonarqube_password" {
  type = string
  description = "Password to connect with sonarqube, this password is to read from sonarqube, not to replace the password value"
  default = "admin"
}
