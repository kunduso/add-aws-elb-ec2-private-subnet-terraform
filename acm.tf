

resource "aws_acm_certificate" "main" {
  domain_name               = "kunduso.com"
  subject_alternative_names = ["*.kunduso.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}