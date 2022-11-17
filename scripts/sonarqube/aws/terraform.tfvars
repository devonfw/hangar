#AWS region code of the location where the resources will be created
region = "eu-west-1"
#Virtual private network (VPC) IP range (CIDR)
vpc_cidr_block = "10.0.0.0/16"
#Subnetwork IP range (CIDR) within VPC
subnet_cidr_block = "10.0.1.0/24"
#Instance private IP within subnet range
nic_private_ip = "10.0.1.50"
#EC2 Instance type
instance_type = "t3a.small"
#Keypair name as defined in AWS
keypair_name = "sonarqube"
#Password to connect with sonarqube, this password is to read from sonarqube, not to replace the password value.
sonarqube_password = "admin"
