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
resource "aws_subnet" "rtesthosts" {
#
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true # Todo, change when ELB is working
}
# Create a subnet to launch our instances into
resource "aws_subnet" "rbuildhosts" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true # Todo, change when ELB is working
}
# Create a subnet to launch our instances into
resource "aws_subnet" "rprodhosts" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = true # Todo, change when ELB is working
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

resource "aws_instance" "rserver" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "rancher"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.small"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.rserver.id}"

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "docker run -d --restart=unless-stopped -p 8080:8080 rancher/server",
    ]
  }
}

resource "aws_instance" "rtesthosts" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  count = "${var.rhoststest_count}"
  connection {
    # The default username for our AMI
    user = "rancher"

    # The connection will use the local SSH agent for authentication.
  }
  # We doesn't want to wait for the os to shutdown
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.small"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.rhosts.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.rtesthosts.id}"

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
 # provisioner "remote-exec" {
 #   inline = [
 #     "sleep 30",
 #     "docker run -e CATTLE_HOST_LABELS='SERVICES=infra'  -d --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.1.3 http://${aws_instance.rserver.public_ip}:8080/v1/scripts/${var.testregistrationtoken}",
  #  ]
  #}
  user_data = <<EOF
#cloud-config  
rancher:
  services:
    rancher-agent1:
      image: rancher/agent:v1.1.3
      privileged: true
      command: http://${aws_instance.rserver.public_ip}:8080/v1/scripts/${var.testregistrationtoken}
      restart: always
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
        - /var/lib/rancher:/var/lib/rancher
EOF
}

resource "aws_instance" "rprodhosts" {
  count = "${var.rhostsprod_count}"

  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "rancher"
  }
  # We doesn't want to wait for the os to shutdown
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.small"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.rhosts.id}"]

  subnet_id = "${aws_subnet.rprodhosts.id}"

  user_data = <<EOF
#cloud-config  
rancher:
  services:
    rancher-agent1:
      image: rancher/agent:v1.1.3
      privileged: true
      command: ${var.produrl}
      restart: always
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
        - /var/lib/rancher:/var/lib/rancher
EOF
}