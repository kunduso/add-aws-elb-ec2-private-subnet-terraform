data "aws_region" "current" {}
locals {
  waf_log           = "/aws/waf/${var.name}-waf-logs"
  principal_root_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  principal_logs_arn = "logs.${data.aws_region.current.name}.amazonaws.com"
  waf_log_group_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.waf_log}"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "${local.waf_log}"
  retention_in_days = 365
  kms_key_id       = aws_kms_key.waf_log.arn
}
resource "aws_kms_key" "waf_log" {
  description             = "KMS key to encrypt load balancer WAF logs."
  deletion_window_in_days = 7
  enable_key_rotation    = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = local.principal_root_arn
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = local.principal_logs_arn
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
                Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" : "${local.waf_log_group_arn}*"
          }
        }
      }
    ]
  })
}
# Add an alias for the KMS key (optional but recommended)
resource "aws_kms_alias" "waf_log" {
  name          = "alias/${var.name}-lb-waf-cloudwatch-logs"
  target_key_id = aws_kms_key.waf_log.key_id
}
# Create KMS key for CloudWatch Logs encryption





