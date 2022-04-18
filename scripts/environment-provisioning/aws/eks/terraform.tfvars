# AWS Region to provision the resources
region="eu-west-1"

# Name for the VPC to be created by the script.
vpc_name="k8s-vpc"

# Parameter for the virtual network IP-Range for creating a new VPC
vpc_cidr_block = "172.16.0.0/16"

# Private and Public Subnet details for creating a new VPC
private_subnets = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
public_subnets = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]

# Instance type for the worker node configuration
instance_type="t3a.small"

# Node group capacity configuration
desired_workers=2
max_workers=4
min_workers=1

# Set this VPC ID only if you already have a VPC available,  
# script will provision the AWS EKS in the given VPC.
#existing_vpc_id="vpc-0573592e893b10c5d"

#existing_vpc_private_subnets=["subnet-064d8edf16da7ada6","subnet-03377c07160bf01ee","subnet-0b2a94866a91fe1b0"]