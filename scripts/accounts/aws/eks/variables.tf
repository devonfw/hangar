 variable "region" {
    description = "The region where to provision resources"
    type = string
}
variable "access_key" {
    description = "The access_key that belongs to the IAM user"
    type = string
}
variable "secret_key" {
    description = "The secret_key that belongs to the IAM user"
    type = string
}
variable "cluster_name" {
    description = "Cluster name for the AWS EKS"
    type = string
}
variable "vpc_cidr_block" {
  type = string
  description = "define your vpc cidr block"
}
