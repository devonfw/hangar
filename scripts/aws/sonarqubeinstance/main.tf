provider "aws" {
  region = "us-east-2"

}

#create VPC
resource "aws_vpc" "sq_vpc" {
  cidr_block = "10.0.0.0/16"


  tags = {
    Name = "sqvpc"
  }
}

#creat internet gateway
resource "aws_internet_gateway" "sq_gateway" {
  vpc_id = aws_vpc.sq_vpc.id

  tags = {
    Name = "sqinternetgateway"
  }
}

#create costum route table
resource "aws_route_table" "sqrouttable" {
  vpc_id = aws_vpc.sq_vpc.id

  # route = [
  #   {
  #     cidr_block = "0.0.0.0/0"
  #     gateway_id = aws_internet_gateway.sq_gateway.id
  #   },
  #   {
  #     ipv6_cidr_block        = "::/0"
  #     gateway_id             = aws_internet_gateway.sq_gateway.id
  #   }
  # ]

  tags = {
    Name = "sqrouttable"
  }
}

resource "aws_route" "sqroute" {
  route_table_id         = aws_route_table.sqrouttable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sq_gateway.id


}

#create subnet
resource "aws_subnet" "subnet_sq" {
  vpc_id     = aws_vpc.sq_vpc.id
  cidr_block = "10.0.1.0/24"


  tags = {
    Name = "sqsubnet"
  }
}
#routtable assoiation
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_sq.id
  route_table_id = aws_route_table.sqrouttable.id

  
}

#create securitygroup
resource "aws_security_group" "allow_web_sq" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
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
    description = "Port9000"
    from_port   = 9000
    to_port     = 9092
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
    Name = "sqsecuritygroup"
  }
}

#networkinterface
resource "aws_network_interface" "sqnic" {
  subnet_id       = aws_subnet.subnet_sq.id
  private_ips     = ["10.0.1.50"] #Ip Adress from the  
  security_groups = [aws_security_group.allow_web_sq.id]

  #   attachment {
  #     instance     = aws_instance.test.id
  #     device_index = 1
  tags = {
    Name = "sqnic"
  }
}

#elastic Ip Adress
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.sqnic.id
  associate_with_private_ip = "10.0.1.50" #Ip Adressrange NIC
  depends_on                = [aws_internet_gateway.sq_gateway]
}

#ubuntu server
resource "aws_instance" "sq-server" {
  ami = "ami-0629230e074c580f2" #Ubuntu 20.04
  #ami             = "ami-020db2c14939a8efb" #Ubuntu 18.04
  instance_type = "t3a.small"
  key_name      = "sonarqube"


  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.sqnic.id
  }


  #auto script for instalation docker
  user_data = file("./datascript.sh")
  # user_data = <<-EOF
  #               #! /bin/bash
  #               echo "script start"
  #               sudo apt-get update
  #               sudo apt-get install docker.io
  #               sudo sysctl -w vm.max_map_count=262144
  #               sudo sysctl -w fs.file-max=65536
  #               ulimit -n 65536
  #               ulimit -u 4096 
  #               sudo docker pull sonarqube:lts
  #               docker volume create sonarqube-conf 
  #               docker volume create sonarqube-data
  #               docker volume create sonarqube-logs
  #               docker volume create sonarqube-extensions
  #               docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 -v sonarqube-conf:/opt/sonarqube/conf -v sonarqube-data:/opt/sonarqube/data -v sonarqube-logs:/opt/sonarqube/logs -v sonarqube-extensions:/opt/sonarqube/extensions sonarqube:lts
  #               echo "skript end"
  #               EOF
  tags = {
    Name = "sqserver"
  }
}

output "elastic-IP" {
  value = aws_eip.one.public_ip
}

