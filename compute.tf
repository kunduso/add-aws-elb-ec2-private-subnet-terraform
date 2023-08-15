
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
resource "aws_instance" "app-server" {
  count                  = length(var.subnet_cidr_private)
  instance_type          = var.instance_type
  ami                    = data.aws_ami.amazon_ami.id
  vpc_security_group_ids = [aws_security_group.ec2_instance.id]
  subnet_id              = element(aws_subnet.private.*.id, count.index)
  tags = {
    Name = "app-2-server-${count.index + 1}"
  }
  user_data = file("user_data/user_data.tpl")
}