#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "ec2_security_group" {
  name        = "${var.name}-Instance-SG"
  description = "Allow inbound and outbound traffic to EC2 instances from load balancer security group"
  vpc_id      = module.vpc.vpc.id
  tags = {
    "Name" = "${var.name}-instance-sg"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ingress_ec2" {
  description              = "allow traffic from the load balancer"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb_security_group.id
  security_group_id        = aws_security_group.ec2_security_group.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "egress_ec2" {
  description       = "allow traffic to the internet."
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_security_group.id
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "lb_security_group" {
  description = "Allow inbound and outbound traffic to load balancer from the internet."
  name        = "${var.name}-LB-SG-IN"
  vpc_id      = module.vpc.vpc.id
  tags = {
    "Name" = "${var.name}-lb-sg"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ingress_load_balancer" {
  description       = "Allow traffic into the load balancer from the internet."
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_security_group.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ingress_from_ec2" {
  description              = "Allow traffic into the load balancer from the EC2 instance."
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_security_group.id
  security_group_id        = aws_security_group.lb_security_group.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "egress_load_balancer" {
  description       = "Allow traffic to reach outside the vpc."
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_security_group.id
}