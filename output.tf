output "load_balancer_dns_name" {
  value = "http://${aws_lb.front.dns_name}"
}