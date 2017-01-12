
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

  # Network to launch in.
  subnet_id = "${aws_subnet.rserver.id}"

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:v1.3.0",
    ]
  }
}

resource "aws_instance" "rbuildhosts" {
  # Number of hosts
  count = "${var.rhostsbuild_count}"
  connection {
    user = "rancher"
  }
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.small"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.rhosts.id}"]
  subnet_id = "${aws_subnet.rbuildhosts.id}"
  # We use cloud-init to set up the server
  user_data = <<EOF
#cloud-config  
rancher:
  services:
    rancher-agent1:
      image: rancher/agent:v1.1.3
      privileged: true
      command: http://${aws_instance.rserver.public_ip}:8080/v1/scripts/${var.buildregistrationtoken}
      restart: always
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
        - /var/lib/rancher:/var/lib/rancher
EOF
}


resource "aws_instance" "rtesthosts" {
  count = "${var.rhoststest_count}"
  connection {
    user = "rancher"
  }
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.small"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.rhosts.id}"]
  subnet_id = "${aws_subnet.rtesthosts.id}"
  user_data = <<EOF
#cloud-config  
rancher:
  services:
    rancher-agent1:
      image: rancher/agent:v1.1.3
      privileged: true
      command: ${var.testurl}
      restart: always
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
        - /var/lib/rancher:/var/lib/rancher
EOF
}

resource "aws_instance" "rprodhosts" {
  count = "${var.rhostsprod_count}"
  connection {
    user = "rancher"
  }
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.small"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${aws_key_pair.auth.id}"
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
