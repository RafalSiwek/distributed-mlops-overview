# Distributed processing-enabled MLOps Infrastructure

This directory contains Terraform modules for provisioning MLOps-focused infrastructure in AWS. The modules support both EKS-based and EC2-based deployments, allowing you to choose the most suitable environment for your machine learning workloads.

## Available Modules

### [EKS Module](`./eks/`)

A production-grade Kubernetes cluster optimized for ML workloads, featuring:
- Managed node groups with GPU support (NVIDIA & AMD)
- Comprehensive monitoring stack (Prometheus & Grafana)
- MLOps tooling (Karpenter, Ray, Volcano scheduler)
- Cost monitoring with Kubecost
- Load balancing and ingress management

### [EC2 Module](`./ec2/`)

Simulated local environments for ML development and testing, offering:
- Single and multi-node configurations
- Support for NVIDIA and AMD GPUs
- MPI-ready setups for distributed training
- Systems Manager (SSM) based access
- Flexible instance type configurations

## Prerequisites

Before deploying either module, ensure you have the following tools and configurations in place:

```bash
# Required tools and versions
terraform >= 1.0
aws-cli >= 2.0
kubectl >= 1.25    # For EKS deployments
helm >= 3.0        # For EKS deployments
```

### AWS Configuration

1. Configure AWS CLI with appropriate credentials:
```bash
aws configure
```

2. Verify your configuration:
```bash
aws sts get-caller-identity
```

## Deployment Instructions

### 1. Variable Configuration

Create a `terraform.tfvars` file in the respective module directory to set your variables:

```hcl
# terraform.tfvars example
region = "us-west-2"
owner  = "team-ml"

# For EKS
training_job_multinode_gpu_enabled = true
ray_cluster_enabled = true

# For EC2
singlenode_multigpu = true
multinode_gpu = false
```

### 2. Infrastructure Provisioning

Navigate to the desired module directory and run:

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Apply the configuration
terraform apply
```

### 3. Post-deployment Steps

For EKS deployments:
```bash
# Configure kubectl
aws eks update-kubeconfig --region <region> --name <cluster_name>

# Verify cluster access
kubectl get nodes
```

For EC2 deployments:
```bash
# List instance IDs
terraform output instance_ids

# Connect via Session Manager
aws ssm start-session --target <INSTANCE_ID>
```

### 4. Cleanup

To destroy the infrastructure when no longer needed:

```bash
# Review destruction plan
terraform plan -destroy

# Destroy resources
terraform destroy
```

> **Note**: For EKS deployments, ensure all services and load balancers are properly removed before destroying the infrastructure to prevent orphaned AWS resources.

## Common Issues & Troubleshooting

- If `terraform destroy` fails for EKS, check for remaining load balancers or persistent volumes
- For EC2 deployments, ensure all instances are running before attempting SSM connections
- AMD GPU instances require manual ROCm installation after deployment

## Next Steps

- Review the individual module READMEs for detailed configuration options
- Check the deployment-specific security considerations
- Configure monitoring and alerting for production deployments

For detailed information about each module, refer to their respective README files in the `eks/` and `ec2/` directories.
