#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
resource "aws_route53_zone" "main" {
  name = var.domain_name
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.front.dns_name
    zone_id                = aws_lb.front.zone_id
    evaluate_target_health = true
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_query_log
resource "aws_route53_query_log" "dns_query" {
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.dns_query_log_group.arn
  zone_id                  = aws_route53_zone.main.zone_id
}