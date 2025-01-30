data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}


data "aws_ami" "nvidia_dl_ubuntu" {
  most_recent = true
  owners      = ["898082745236"]
  filter {
    name   = "name"
    values = ["Deep Learning OSS Nvidia Driver AMI GPU PyTorch 2.5.* (Ubuntu 22.04)*"]
  }
}

data "aws_availability_zones" "available" {}

locals {
  common_tags = {
    Terraform = true,
    Project   = "mlops"
    Owner     = var.owner
  }
  resource_prefix = "${local.common_tags.Owner}-${local.common_tags.Project}"
  vpc_cidr        = "10.10.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 1)
}
