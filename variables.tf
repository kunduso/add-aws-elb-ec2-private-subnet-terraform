#Define AWS Region
variable "region" {
  description = "Infrastructure region"
  type        = string
  default     = "us-east-2"
}
#Define IAM User Access Key
variable "access_key" {
  description = "The access_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  default     = ""
}
#Define IAM User Secret Key
variable "secret_key" {
  description = "The secret_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  default     = ""
}
variable "vpc_cidr" {
  description = "The cidr of the vpc"
  default     = "10.20.20.0/24"
  type        = string
}
variable "subnet_cidr_private" {
  description = "cidr blocks for the private subnets"
  default     = ["10.20.20.0/27", "10.20.20.32/27", "10.20.20.64/27"]
  type        = list(any)
}
variable "subnet_cidr_public" {
  description = "cidr blocks for the public subnets"
  default     = ["10.20.20.96/27", "10.20.20.128/27", "10.20.20.160/27"]
  type        = list(any)
}
variable "name" {
  description = "The name of the application."
  type        = string
  default     = "app-2"
}
variable "ami_name" {
  description = "The ami name of the image from where the instances will be created"
  default     = ["amzn2-ami-amd-hvm-2.0.20250220.0-x86_64-gp2"]
  type        = list(string)
}
variable "instance_type" {
  description = "The instance type of the EC2 instances"
  default     = "t3.medium"
  type        = string
}
variable "domain_name" {
  description = "The domain name of the application."
  type        = string
  default     = "kunduso.com"
}