terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = {
      Source = "https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform"
    }
  }
}
# Provider for us-east-1 (required for DNS query logging)
provider "aws" {
  alias      = "us-east-1"
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = {
      Source = "https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform"
    }
  }
}