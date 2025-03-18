
resource "aws_route53_zone" "main" {
  name = "kunduso.com"
  #checkov:skip=CKV2_AWS_39: Domain Name System (DNS) query logging is not enabled for Amazon Route 53 hosted zones
  #This check is disabled since this use case is for non-prod environment.
}
resource "time_sleep" "wait_for_dns_propagation" {
  depends_on      = [aws_route53_zone.main]
  create_duration = "60s" # 5 minutes
}

resource "aws_route53_hosted_zone_dnssec" "dns" {
  depends_on = [
    time_sleep.wait_for_dns_propagation,
    aws_route53_key_signing_key.main,
    aws_acm_certificate_validation.main
  ]
  hosted_zone_id = aws_route53_zone.main.id
}
resource "aws_route53_key_signing_key" "main" {
  hosted_zone_id             = aws_route53_zone.main.id
  key_management_service_arn = aws_kms_key.dnssec.arn
  name                       = "${var.name}-key"
  status                     = "ACTIVE"
}
resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "kunduso.com"
  type    = "A"

  alias {
    name                   = aws_lb.front.dns_name
    zone_id                = aws_lb.front.zone_id
    evaluate_target_health = true
  }
}

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

resource "aws_kms_key" "dnssec" {
  provider                 = aws.us-east-1 # Must be in us-east-1
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
}

resource "aws_kms_alias" "dnssec" {
  provider      = aws.us-east-1
  name          = "alias/${var.name}-dnssec"
  target_key_id = aws_kms_key.dnssec.key_id
}

resource "aws_kms_key_policy" "dnssec" {
  provider = aws.us-east-1
  key_id   = aws_kms_key.dnssec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Route 53 DNSSEC Service"
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
          "kms:UpdateKeyDescription",
          "kms:UpdateAlias",
          "kms:PutKeyPolicy"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Route 53 DNSSEC to CreateGrant"
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Action   = "kms:CreateGrant"
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
}
