# Distributed processing-enabled EC2 MLOps Infrastructure Terraform Module

This module deploys EC2 instances designed to simulate local environments for machine learning workloads, supporting both NVIDIA and AMD GPUs, as well as CPU-only configurations.

## Features

- Multiple instance type configurations for different ML workloads
- Support for both NVIDIA and AMD GPU instances
- Multi-node deployment capabilities
- VPC with private and public subnets
- Session Manager (SSM) access to instances
- Security group configuration for inter-instance communication

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- AWS Systems Manager (SSM) for instance access

## Required Providers

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.21"
    }
  }
}
```

## Variables

### Required Variables
None - all variables have default values.

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| region | AWS Region | string | "eu-west-1" |
| owner | Infrastructure owner name | string | "distributed" |
| singlenode_multigpu | Deploy instance with multiple GPUs | bool | false |
| multinode_gpu | Deploy multiple NVIDIA GPU instances | bool | false |
| multinode_gpu_amd | Deploy multiple AMD GPU instances | bool | false |
| multinode | Deploy multiple standard instances | bool | false |
| multinode_mpi | Deploy instances for MPI workload | bool | false |

## Usage

### Basic Example

```hcl
module "mlops_ec2" {
  source = "path/to/module"
  
  region = "us-west-2"
  owner  = "team-ml"
}
```

### Multi-GPU Example

```hcl
module "mlops_ec2" {
  source = "path/to/module"
  
  region            = "us-west-2"
  owner             = "team-ml"
  singlenode_multigpu = true
}
```

## Infrastructure Components

### VPC Configuration
- Private and public subnets in a single availability zone
- NAT Gateway for private subnet internet access
- Internet Gateway for public subnet access

### Instance Types and Configurations

1. Multi-GPU Instance (g4dn.12xlarge)
   - Enabled with `singlenode_multigpu = true`
   - Uses NVIDIA Deep Learning AMI
   - 4 NVIDIA T4 GPUs

2. Single GPU Instance (g4dn.xlarge)
   - Enabled with `multinode_gpu = true`
   - Uses NVIDIA Deep Learning AMI
   - Single NVIDIA T4 GPU

3. AMD GPU Instance (g4ad.xlarge)
   - Enabled with `multinode_gpu_amd = true`
   - Uses Ubuntu base AMI
   - Requires manual ROCm installation

4. CPU Instances
   - Standard nodes (t3.xlarge)
   - MPI worker nodes (t3.micro)
   - Deployed in pairs when enabled

### Storage
- All instances come with 200GB root volume
- EBS volumes are GP3 by default

### Security

#### IAM Configuration
- IAM role for Systems Manager access
- Instance profile for SSM authentication

#### Security Groups
- Allows full communication between instances
- Permits outbound internet access
- Internal instance-to-instance communication enabled

## Access and Management

### Connecting to Instances

Use AWS Systems Manager Session Manager to connect:
```bash
aws ssm start-session --target <INSTANCE_ID> --document-name AWS-StartInteractiveCommand --parameters command="bash -l"
```

### Outputs

The module outputs the following:
- `instance_ids`: List of IDs for all created instances

## Instance Specifics

### NVIDIA GPU Instances
- Pre-installed with NVIDIA drivers and PyTorch 2.5
- Ready for deep learning workloads
- Automatic GPU configuration

### AMD GPU Instances
- Requires manual ROCm installation
- Follow [ROCm installation guide](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/)
- Basic Ubuntu 22.04 AMI

### CPU-only Instances
- Ubuntu 22.04 base image
- Suitable for distributed training coordination
- MPI-ready configuration

## Limitations and Known Issues

1. Single availability zone deployment
2. Fixed root volume size
3. Manual ROCm installation required for AMD instances
4. Single NAT Gateway (consider multiple for production)

## Security Considerations

- Instances are not directly accessible from the internet
- Access is managed through Systems Manager
- Security groups allow necessary internal communication
- All instances are in private subnets

## License

Refer to the repository's LICENSE file for licensing information.