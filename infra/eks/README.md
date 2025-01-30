# Distributed processing-enabled EKS MLOps Infrastructure Terraform Module

This module sets up a test EKS infrastructure optimized for MLOps workloads, including GPU support, autoscaling, monitoring, and essential Kubernetes add-ons.

## Features

- Amazon EKS cluster with managed node groups
- VPC with public and private subnets
- Karpenter for automated node provisioning
- Support for both NVIDIA and AMD GPU workloads
- Comprehensive monitoring with Prometheus and Grafana
- Kubernetes Dashboard for cluster management
- Cost monitoring with Kubecost
- Support for distributed training with Volcano scheduler
- Ray cluster support for distributed computing
- Load balancing with AWS Load Balancer Controller
- Ingress management with NGINX Ingress Controller

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- kubectl installed
- Helm v3

## Required Providers

```hcl
terraform {
  required_providers {
    aws        = "~> 5.0"
    kubernetes = ">= 2.35"
    helm       = ">= 2.17.0"
    kubectl    = ">= 1.19"
    random     = ">= 3.1"
    null       = ">= 3.1"
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
| eks_cluster_version | EKS Cluster version | string | "1.31" |
| vpc_cidr | VPC CIDR block | string | "10.1.0.0/21" |
| secondary_cidr_blocks | Secondary CIDR blocks for VPC | list(string) | ["100.64.0.0/16"] |
| training_job_multinode_gpu_enabled | Enable GPU support for training jobs | bool | false |
| training_job_multinode_enabled | Enable multinode training support | bool | false |
| ray_cluster_enabled | Enable Ray cluster support | bool | false |
| volcano_scheduler_enabled | Enable Volcano scheduler support | bool | false |


## Usage

### Basic Example

```hcl
module "eks_mlops" {
  source = "path/to/module"
  
  region             = "us-west-2"
  owner              = "team-ml"
  eks_cluster_version = "1.31"
}
```

### GPU-Enabled Example

```hcl
module "eks_mlops" {
  source = "path/to/module"
  
  region                              = "us-west-2"
  owner                              = "team-ml"
  training_job_multinode_gpu_enabled = true
  training_job_multinode_enabled     = true
}
```

## Infrastructure Components

### VPC Configuration
- Creates a VPC with both public and private subnets
- Supports secondary CIDR blocks for pod IP addressing
- NAT Gateway for private subnet internet access
- Internet Gateway for public subnet access

### EKS Cluster
- Managed node groups for core system components
- IRSA (IAM Roles for Service Accounts) configuration
- EBS CSI Driver for persistent storage
- GP3 as default storage class

### Node Groups and Pools
1. Core Node Group
   - Used for system add-ons and critical components
   - Based on m5.xlarge instances
   - Minimum 3 nodes, maximum 8 nodes

2. Karpenter Node Pools
   - Training Operator Job Pool (CPU)
   - NVIDIA GPU Pool (g4dn instances)
   - AMD GPU Pool (g4ad instances)
   - Ray Cluster Head and Worker Pools

### Add-ons and Tools

#### Monitoring Stack
- Prometheus for metrics collection
- Grafana for visualization
- Stored credentials in AWS Secrets Manager

#### Development Tools
- Kubernetes Dashboard
- Kubecost for cost monitoring
- AWS Load Balancer Controller
- NGINX Ingress Controller

#### ML/AI Specific Tools
- NVIDIA GPU Operator
- AMD ROCm Device Plugin
- Volcano Scheduler
- KubeRay Operator (when Ray support is enabled)

## Post-deployment Steps

1. Configure kubectl:
```bash
aws eks --region <region> update-kubeconfig --name <cluster_name>
```

2. Access Grafana:
```bash
kubectl port-forward svc/kube-prometheus-stack-grafana 8080:80 -n kube-prometheus-stack
```
- Default username: admin
- Get password from AWS Secrets Manager:
```bash
aws secretsmanager get-secret-value --secret-id <grafana_secret_name> --region <region> --query "SecretString" --output text
```

3. Access Kubernetes Dashboard:
```bash
kubectl port-forward service/kubernetes-dashboard-kong-proxy -n kubernetes-dashboard 8443:443
```
- Get authentication token:
```bash
aws eks get-token --cluster-name <cluster_name> --region <region>
```

## Security Considerations

- Public endpoint access is enabled for demonstration purposes only
- Production deployments should implement appropriate security controls
- Default security groups allow required communication between nodes
- SSL/TLS termination available through ALB
- Secrets managed through AWS Secrets Manager

## Limitations and Known Issues

1. Public endpoint access is enabled by default (not recommended for production)
2. Single NAT Gateway is used (consider multiple for production)
3. AMD GPU support is limited to specific instance types
4. Default monitoring retention periods may need adjustment for production use
5. The Loadbalancer add-on provisions an AWS ELB, but Terraform does manage its cleanup - it has to be done manualy

## License

Refer to the repository's LICENSE file for licensing information.

## Honorable mention

This setup was inspired by AWS [data on EKS](https://github.com/awslabs/data-on-eks/tree/main) projects

