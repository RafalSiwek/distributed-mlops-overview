data "aws_availability_zones" "available" {}

# Used for Karpenter Helm chart
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.ecr_public_region
}

locals {
  common_tags = {
    Terraform = true,
    Project   = "mlops"
    Owner     = var.owner
  }
  resource_prefix = "${local.common_tags.Owner}-${local.common_tags.Project}"

  region = var.region

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  nodeclass_name = "${local.common_tags.Owner}-${local.common_tags.Project}-workers"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu-eks/k8s_1.31/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
