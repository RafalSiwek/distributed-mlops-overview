module "g4dn_12xlarge_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = var.singlenode_multigpu ? 1 : 0

  name = "${local.resource_prefix}-g4dn-12xlarge-${count.index}"

  instance_type = "g4dn.12xlarge"
  ami           = data.aws_ami.nvidia_dl_ubuntu.id

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  root_block_device = [{
    volume_size = 200
  }]

  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  subnet_id              = module.vpc.private_subnets[0]
}

module "g4dn_xlarge_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = var.multinode_gpu ? 1 : 0

  name = "${local.resource_prefix}-g4dn-xlarge-${count.index}"

  instance_type = "g4dn.xlarge"
  ami           = data.aws_ami.nvidia_dl_ubuntu.id

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  root_block_device = [{
    volume_size = 200
  }]

  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  subnet_id              = module.vpc.private_subnets[0]
}

module "g4ad_xlarge_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = var.multinode_gpu_amd ? 1 : 0

  name = "${local.resource_prefix}-g4ad-xlarge-${count.index}"

  instance_type = "g4ad.xlarge"
  # There is no AMI with pre-installed ROCm software installed
  # All has to be done manually
  # See: https://rocm.docs.amd.com/projects/install-on-linux/en/latest/
  ami = data.aws_ami.ubuntu.id

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  root_block_device = [{
    volume_size = 200
  }]

  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  subnet_id              = module.vpc.private_subnets[0]
}

module "t3_xlarge_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = var.multinode || var.multinode_mpi ? 2 : 0

  name = "${local.resource_prefix}-t3-xlarge-${count.index}"

  instance_type = "t3.xlarge"
  ami           = data.aws_ami.ubuntu.id

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  root_block_device = [{
    volume_size = 200
  }]

  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  subnet_id              = module.vpc.private_subnets[0]
}

module "t3_micro_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = var.multinode_mpi ? 1 : 0

  name = "${local.resource_prefix}-t3-micro-${count.index}"

  instance_type = "t3.micro"
  ami           = data.aws_ami.ubuntu.id

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  root_block_device = [{
    volume_size = 200
  }]

  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  subnet_id              = module.vpc.private_subnets[0]
}
