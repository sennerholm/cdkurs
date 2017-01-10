#output "address" {
#  value = "${aws_elb.rserver.dns_name}"
#}

output "hostip" {
  value = "${aws_instance.rserver.public_ip}"
}

output "Rancherserver-url" {
  value = "http://${aws_instance.rserver.public_ip}:8080"
}
output "rtesthosts" {
  value = "${join( "," , aws_instance.rtesthosts.*.public_ip ) }"
}
