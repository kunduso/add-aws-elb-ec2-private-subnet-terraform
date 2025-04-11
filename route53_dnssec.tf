
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
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ]
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" : true
          }
        }
      }
    ]
  })
  depends_on = [aws_kms_key.dnssec]
}
resource "aws_route53_key_signing_key" "main" {
  hosted_zone_id             = aws_route53_zone.main.id
  key_management_service_arn = aws_kms_key.dnssec.arn
  name                       = "${var.name}-key"
  status                     = "ACTIVE"
  depends_on                 = [aws_kms_key.dnssec, aws_kms_key_policy.dnssec]
}
resource "aws_route53_hosted_zone_dnssec" "dns" {
  depends_on = [
    aws_route53_key_signing_key.main,
    aws_acm_certificate_validation.main
  ]
  hosted_zone_id = aws_route53_zone.main.id
}