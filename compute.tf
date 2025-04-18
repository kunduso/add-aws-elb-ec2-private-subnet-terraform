#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "amazon_ami" {
  filter {
    name   = "name"
    values = var.ami_name
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners      = ["amazon"]
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "app-server" {
  count                  = length(var.subnet_cidr_private)
  instance_type          = var.instance_type
  ami                    = data.aws_ami.amazon_ami.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  subnet_id              = element(module.vpc.private_subnets.*.id, count.index)
  ebs_optimized          = true
  monitoring             = true
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  root_block_device {
    encrypted = true
  }
  tags = {
    Name = "${var.name}-server-${count.index + 1}"
  }
  user_data = filebase64("./user_data/user_data.tpl")
  #checkov:skip=CKV2_AWS_41: Ensure an IAM role is attached to EC2 instance
  #This EC2 instance does not interact with any AWS service
}