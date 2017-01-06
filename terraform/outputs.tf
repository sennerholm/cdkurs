output "address" {
  value = "${aws_elb.web.dns_name}"
}
output "hostdns" {
  value = "${aws_instance.web.public_dns}"
}

output "hostip" {
  value = "${aws_instance.web.public_ip}"
}
