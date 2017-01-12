variable "rancher_access_key" {
  type = "string"
  default = "A1E2C6E9FC637154D6B3"
}
variable "rancher_secret_key" {
  type = "string"
  default = "LxEnc8ctqtzPFyCJvbG8s1Zi6wkjcMMs9CtN84nX"
}

# Configure the Rancher provider
provider "rancher" {
  api_url = "http://${aws_instance.rserver.public_ip}:8080"
  access_key = "${var.rancher_access_key}"
  secret_key = "${var.rancher_secret_key}"
}

# Create a new Rancher environment
resource "rancher_environment" "test" {
  name = "test"
  description = "The test environment"
  orchestration = "cattle"
}

# Create a new Rancher registration token
resource "rancher_registration_token" "test" {
  name = "staging_token"
  description = "Registration token for the staging environment"
  environment_id = "${rancher_environment.test.id}"
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
      command: http://${aws_instance.rserver.public_ip}:8080/v1/scripts/${rancher_registration_token.test.token}
      restart: always
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
        - /var/lib/rancher:/var/lib/rancher
EOF
}

# Create a new Rancher environment
resource "rancher_environment" "prod" {
  name = "prod"
  description = "The prod environment"
  orchestration = "cattle"
}

# Create a new Rancher registration token
resource "rancher_registration_token" "prod" {
  name = "staging_token"
  description = "Registration token for the staging environment"
  environment_id = "${rancher_environment.prod.id}"
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
      command: http://${aws_instance.rserver.public_ip}:8080/v1/scripts/${rancher_registration_token.prod.token}
      restart: always
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
        - /var/lib/rancher:/var/lib/rancher
EOF
}
