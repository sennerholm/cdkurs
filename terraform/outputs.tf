#output "address" {
#  value = "${aws_elb.rserver.dns_name}"
#}

output "hostip" {
  value = "${aws_instance.rserver.public_ip}"
}

output "Rancherserver-url" {
  value = "http://${aws_instance.rserver.public_ip}:8080"
}
output "rbuildhosts" {
  value = "${join( "," , aws_instance.rbuildhosts.*.public_ip ) }"
}
