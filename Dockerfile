FROM ubuntu:16.04
MAINTAINER mikael@sennerholm.net
# Description:
#  Contains all tools needed to run the cd lab
# Install curl/git/jq
RUN apt-get update && \
    apt-get install -y curl git jq unzip && \
    apt-get clean # Clean up
# Install rancher cli https://github.com/rancher/cli/releases
RUN curl -L -o /tmp/rancher.tgz https://github.com/rancher/cli/releases/download/v0.4.1/rancher-linux-amd64-v0.4.1.tar.gz && \
	tar zxvf /tmp/rancher.tgz && \
	mv rancher-*/rancher /usr/local/bin/rancher && \
	rm -rf rancher-*
# terraform 
RUN curl -o /tmp/terraform.tgz https://releases.hashicorp.com/terraform/0.8.3/terraform_0.8.3_linux_amd64.zip && \
  unzip /tmp/terraform.tgz && \
  mv terraform /usr/local/bin/terraform
 