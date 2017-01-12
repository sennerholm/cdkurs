variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
  default = "~/.ssh/id_rsa.pub"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "default"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

# AMI (x64)
variable "aws_amis" {
  default = {
#    eu-west-1 = "ami-b1cf19c6"
#    eu-west-1 = "ami-e2065591" # Rancher os 0.7.1 without ECS
#    "ami-a51e47d6"
     eu-west-1 = "ami-c62170b5" # Från https://github.com/rancher/os/blob/master/README.md/#user-content-amazon
    eu-west-2 = "ami-65e8e201"
    us-east-1 = "ami-dfdff3c8"
    us-west-1 = "ami-da2075ba"
    us-west-2 = "ami-ab3192cb"
  }
}

# Change to 3 later when you have the correct token below
variable "rhostsbuild_count" {
  type = "string"
  default = "0"
}

variable "buildregistrationtoken" {
  type = "string"
  default = "CHANGE"
}
# Override in an override.tf file
# Change to 3 later when you have the correct token below
variable "rhoststest_count" {
  type = "string"
  default = "0"
}

variable "testurl" {
  type = "string"
  default = "Dummy, change by script in override file"
}

# Create override for prod
# Combo of: https://thepracticalsysadmin.com/category/rancher/ and  https://gist.github.com/mathuin/ed0fa5666e4f063b94abb5b1a49d9919
# mikan@t460s:~/cag/cdkurs/terraform$ rancher env create prod
# 1a68
# Create registration key 
# curl -s -u ${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY} -X POST -H "Accept: application/json" -H "Content-Type: application/json" ${RANCHER_URL}/v1/projects/$PID/registrationTokens | jq -r '.id'
# https://thepracticalsysadmin.com/category/rancher/
# RANCHER_PROD_URL=$(curl  -s -u ${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY} ${RANCHER_URL}/v1/registrationtokens?projectId=$PROJID | head -1 | grep -nhoe 'registrationUrl[^},]*}' | egrep -hoe 'https?:.*[^"}]')
# RANCHER_PROD_REALURL=`echo $RANCHER_PROD_URL | sed 's-\\\\--g'`
# echo -e "variable \"produrl\" {\n  type = \"string\"\n  default = \"${RANCHER_PROD_REALURL}\"\n}" > variablesauto.tf

# Change to 3 override file
variable "rhostsprod_count" {
  type = "string"
  default = "0"
}

variable "produrl" {
  type = "string"
  default = "Dummy, change by script in override file"
}

