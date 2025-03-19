output "route53_name_servers" {
  value = "${aws_route53_zone.main.name_servers}"
}