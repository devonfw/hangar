variable "aws_region" {
  type = string
  description = "wich reson you want to deploy on aws"
}

variable "vpc_cdir_block" {
  type = string
  description = "defin your cdir_block"
}

variable "subnet_cdir_block" {
  type = string
  description = "subnet cdir block"
}
variable "nic_privat_ip" {
    type = string
    description = "privat ip in the range from the subnet cdir "
  
}

variable "instance_type" {
  type = string
  description = "instance_type"
}

variable "ami_ubuntu_20_04" {
  type = string
  description = "deploy Ubuntu 20.04 LTS"
}

variable "aim_ubuntu_18_04" {
  type = string
  description = "deploy Ubuntu 18.04 LTS"
}

variable "key_name" {
  type = string
  description = "Name of the key"
}