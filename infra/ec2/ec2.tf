resource "aws_iam_role" "ec2_ssm_role" {
  name = "${local.resource_prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Connecting to instances will be done ower SSM Manager
# To connect to the instance run:
# aws ssm start-session --target <INSTANCE_ID> --document-name AWS-StartInteractiveCommand --parameters command="bash -l"
resource "aws_iam_role_policy_attachment" "ssm_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2_ssm_role.name
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${local.resource_prefix}-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_security_group" "instance_sg" {
  name        = "${local.resource_prefix}-instance-sg"
  description = "Security group for ML training instances"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress to internet"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow full internal communication"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow full internal communication"
  }
}
