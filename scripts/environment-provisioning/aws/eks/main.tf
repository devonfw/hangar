terraform {
  backend "s3" {    
  }
}

provider "aws" {
  region     = var.region  
}

# Add multiple  availability zones here
data "aws_availability_zones" "available" {

}

module "vpc" {
  count = (var.existing_vpc_id == "none" ? 1 : 0)
  source  = "terraform-aws-modules/vpc/aws"
  
  name                 = var.vpc_name
  cidr                 = var.vpc_cidr_block
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.21"

  vpc_id =  (var.existing_vpc_id == "none" ? module.vpc[0].vpc_id : var.existing_vpc_id)
  subnets = (var.existing_vpc_id == "none" ? module.vpc[0].private_subnets : var.existing_vpc_private_subnets)

  node_groups = {
    first = {
      desired_capacity = var.desired_workers
      max_capacity     = var.max_workers
      min_capacity     = var.min_workers

      instance_type = var.instance_type
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token 
}