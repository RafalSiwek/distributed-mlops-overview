terraform {
  required_providers {
    aws = {
      version = "~> 5.21"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.common_tags
  }
}
