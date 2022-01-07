#Parameter for the region in aws where to deploy
aws_region = "eu-west-1"
#Parameter for the virtual network IP-Range
vpc_cidr_block = "10.0.0.0/16"
#Parameter for the subnetwork IP-Range. Need to be a subnet ip range from the Network
subnet_cidr_block = "10.0.1.0/24"
#Parameter for the private IP from the nic. Need to be an IP from subnet
nic_private_ip = "10.0.1.50"
#Parameter of the instance type of the EC2 Instance
instance_type = "t3a.small"
#Parameter of the Key you use in aws
key_name = "sonarqube"
