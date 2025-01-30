module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.resource_prefix
  cidr = local.vpc_cidr

  enable_nat_gateway = true
  single_nat_gateway = true

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 4)]
}
