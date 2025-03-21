data "aws_caller_identity" "current" {}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "front" {
  name     = "${var.name}-front"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc.id
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 10
    matcher             = 200
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 3
    unhealthy_threshold = 2
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "attach-ec2" {
  count            = length(aws_instance.app-server)
  target_group_arn = aws_lb_target_group.front.arn
  target_id        = element(aws_instance.app-server.*.id, count.index)
  port             = 80
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }

  }
}
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.front.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }
  depends_on = [aws_acm_certificate_validation.main]
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "front" {
  name                       = "${var.name}-front"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_security_group.id]
  subnets                    = [for subnet in module.vpc.public_subnets : subnet.id]
  enable_deletion_protection = false
  drop_invalid_header_fields = true
  access_logs {
    bucket  = aws_s3_bucket.artifacts.id
    enabled = true
  }
  depends_on = [aws_s3_bucket_policy.alb_logs]
  tags = {
    Environment = "Development"
  }
  #checkov:skip=CKV2_AWS_28: Ensure public facing ALB are protected by WAF
  #This check is disabled since this use case is for non-prod environment.
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${var.name}-artifacts"
  force_destroy = true

  #checkov:skip=CKV_AWS_18: AWS Access logging not enabled on S3 buckets
  #checkov:skip=CKV2_AWS_61: An S3 bucket must have a lifecycle configuration
  #Above rules are for deprecated properties.

  #checkov:skip=CKV_AWS_144: S3 bucket cross-region replication disabled
  #This bucket is used for storing access logs for the load balancer, and does not require another bucket to store this bucket's access logs.

  #checkov:skip=CKV_AWS_21: AWS S3 Object Versioning is disabled
  #The items in this S3 bucket do not require versioning.

  #checkov:skip=CKV2_AWS_62: S3 buckets do not have event notifications enabled
  #The items in this s3 bucket are access logs and do not require any event notifications to be sent anywhere.
}
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt_bucket" {
  bucket = aws_s3_bucket.artifacts.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
#https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html#attach-bucket-policy
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.artifacts.id

policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowELBRootAccount"
        Effect = "Allow"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.artifacts.arn}/*"
        Principal = {
          AWS = "arn:aws:iam::033677994240:root"  # us-east-2 ELB account
        }
      }
    ]
  })
}
