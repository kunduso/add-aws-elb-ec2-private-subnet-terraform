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
resource "aws_lb_target_group_attachment" "attach-app2" {
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
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "${var.name}-lb-access-logs"
    enabled = true
  }
  tags = {
    Environment = "Development"
  }
  #checkov:skip=CKV2_AWS_28: Ensure public facing ALB are protected by WAF
  #This check is disabled since this use case is for non-prod environment.
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "lb_logs" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.name}-artifacts"
}