#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region
data "aws_region" "us-east-1" {
  provider = aws.us-east-1
}
locals {
  dns_query_log                = "/aws/route53/${var.name}/dns-query-logs"
  principal_logs_us-east-1_arn = "logs.${data.aws_region.us-east-1.name}.amazonaws.com"
  dns_query_log_group_arn      = "arn:aws:logs:${data.aws_region.us-east-1.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.dns_query_log}"
}
# Create CloudWatch log group to store DNS query logs
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "dns_query_log_group" {
  provider          = aws.us-east-1
  name              = local.dns_query_log
  retention_in_days = 365
  kms_key_id        = aws_kms_key.dns_query_log.arn
}
# Create a KMS Key to encrypt the CloudWatch logs
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "dns_query_log" {
  provider                = aws.us-east-1
  description             = "KMS key to encrypt DNS query logs."
  deletion_window_in_days = 7
  enable_key_rotation     = true

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
          Service = local.principal_logs_us-east-1_arn
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
            "kms:EncryptionContext:aws:logs:arn" : "${local.dns_query_log_group_arn}*"
          }
        }
      }
    ]
  })
}
# Create an alias for the KMS key
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
resource "aws_kms_alias" "dns_query_log" {
  provider      = aws.us-east-1
  name          = "alias/${var.name}-dns-query-cloudwatch-logs"
  target_key_id = aws_kms_key.dns_query_log.key_id
}