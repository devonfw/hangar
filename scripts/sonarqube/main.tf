provider "aws" {
  region = var.aws_region

}

#create VPC
resource "aws_vpc" "sq_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "sonarqube_vpc"
  }
}

#create internet gateway
resource "aws_internet_gateway" "sq_gateway" {
  vpc_id = aws_vpc.sq_vpc.id

  tags = {
    Name = "sonarqube_internetgateway"
  }
}

#create custom route table
resource "aws_route_table" "sq_routetable" {
  vpc_id = aws_vpc.sq_vpc.id

  tags = {
    Name = "sonarqube_routetable"
  }
}

#create default route
resource "aws_route" "sq_route" {
  route_table_id         = aws_route_table.sq_routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sq_gateway.id
}

#create subnet
resource "aws_subnet" "sq_subnet" {
  vpc_id     = aws_vpc.sq_vpc.id
  cidr_block = var.subnet_cidr_block

  tags = {
    Name = "sonarqube_subnet"
  }
}

#associate route table 
resource "aws_route_table_association" "sq_route_table_association" {
  subnet_id      = aws_subnet.sq_subnet.id
  route_table_id = aws_route_table.sq_routetable.id
}

#create security group
resource "aws_security_group" "sq_securitygroup" {
  name        = "sonarqube_securitygroup"
  description = "SonarQube Security Group"
  vpc_id      = aws_vpc.sq_vpc.id
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "sonarqube_securitygroup"
  }
}

#create network interface (NIC)
resource "aws_network_interface" "sq_nic" {
  subnet_id       = aws_subnet.sq_subnet.id
  private_ips     = [var.nic_private_ip]   
  security_groups = [aws_security_group.sq_securitygroup.id]

  tags = {
    Name = "sonarqube_nic"
  }
}

#create elastic IP associated to NIC
resource "aws_eip" "sq_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.sq_nic.id
  associate_with_private_ip = var.nic_private_ip 
  depends_on                = [aws_internet_gateway.sq_gateway]
}

#create EC2 instance
resource "aws_instance" "sq_server" {
  ami = data.aws_ami.ubuntu_20_04.id 
  instance_type = var.instance_type
  key_name      = var.keypair_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.sq_nic.id
  }

  #cloud config script for setting up SonarQube
  user_data = file("./setup_sonarqube.sh")
 
  tags = {
    Name = "sonarqube_server"
  }
}

#Get Ubuntu 20.04 AMI for EC2 Instance
data "aws_ami" "ubuntu_20_04" {
    most_recent = true
 
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
 
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
 
    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
 
    owners = ["099720109477"] # Canonical official
}

#outputs
output "sonarqube_public_ip" {
  value = aws_eip.sq_eip.public_ip
}
