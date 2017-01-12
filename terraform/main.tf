# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  shared_credentials_file  = "aws/credentials"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our ELBs into
resource "aws_subnet" "elb" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create a subnet to launch our instances into
resource "aws_subnet" "rserver" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

# Create a subnet to launch our instances into
resource "aws_subnet" "rbuildhosts" {
#
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true 
}
# Create a subnet to launch our instances into
resource "aws_subnet" "rtesthosts" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true 
}
# Create a subnet to launch our instances into
resource "aws_subnet" "rprodhosts" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = true 
}


# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "rserver_elb" {
  name        = "rserver_elb"
  description = "Rancher server"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTP (8080) access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "DefaultSec"
  description = "Default security groups for our vpc"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the ELBVPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for rancher hosts so they can 
# reach each other on UDP 4500 and 500
# http://docs.rancher.com/rancher/v1.3/en/hosts/custom/

resource "aws_security_group" "rhosts" {
  name        = "Rhost"
  description = "Default security groups for our rancher hosts"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the ALL
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
#    cidr_blocks = ["10.0.1.0/24"]
  }
  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Go access from anywhere
  ingress {
    from_port   = 8153
    to_port     = 8153
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   # HTTPs access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

 # 500/4500 access from own networks
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # 500/4500 access from own networks
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
   cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
# ELB Currently not get contact with backend host so we skip this
#resource "aws_elb" "rserver" {
#  name = "terraform-rserver-elb"
#
#  subnets         = ["${aws_subnet.elb.id}"]
#  security_groups = ["${aws_security_group.rserver_elb.id}"]
#  instances       = ["${aws_instance.rserver.id}"]
#
#  listener {
#    instance_port     = 8080
#    instance_protocol = "http"
#    lb_port           = 8080
#    lb_protocol       = "http"
#  }
#}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}
