# Distributed MLOps Infrastructure Project

This project provides a comprehensive infrastructure setup for distributed machine learning (ML) workloads on Kubernetes (K8s) using **Amazon EKS**. It includes Terraform modules for provisioning the infrastructure, Docker configurations for building custom images, and example scripts for running distributed training jobs using various frameworks and schedulers.

## Project Overview

The project is organized into three main directories:

1. **[`infra/`](infra/)**: Contains Terraform modules for provisioning the EKS cluster, GPU support, and distributed training tools.
2. **[`docker/`](docker/)**: Includes Docker configurations for building custom images for MPI, GPU, and distributed training workloads.
3. **[`examples/`](examples)**: Provides example scripts and configurations for running distributed training jobs using:
   - **Ray**
   - **Torchrun**
   - **MPI**
   - **Training Operator**
   - **Volcano Scheduler**

## Directory Structure

```
.
├── docker/                     # Docker configurations for custom images
│   ├── g4ad_rocm_build/        # AMD GPU (ROCm) build
│   ├── g4dn_cuda_build/        # NVIDIA GPU (CUDA) build
│   └── standard_mpi_runner/    # Standard MPI runner
├── examples/                   # Example scripts and configurations
│   ├── kuberay/                # Ray cluster examples
│   ├── local/                  # Local distributed training examples
│   ├── mpi/                    # MPI-based distributed training examples
│   ├── ray/                    # Ray-based distributed training examples
│   ├── torchrun/               # Torchrun-based distributed training examples
│   ├── training_operator/      # Training Operator examples
│   └── volcano_scheduler/      # Volcano Scheduler examples
└── infra/                      # Terraform modules for EKS infrastructure
    ├── ec2/                    # EC2 instance configurations
    └── eks/                    # EKS cluster configurations
```

## Key Features

- **EKS Cluster**: Fully managed Kubernetes cluster with GPU support.
- **Distributed Training**: Support for Ray, Torchrun, MPI, Training Operator, and Volcano Scheduler.
- **GPU Support**: Configurations for both NVIDIA (CUDA) and AMD (ROCm) GPUs.
- **Monitoring**: Integrated Prometheus and Grafana for cluster monitoring.
- **Cost Management**: Kubecost for cost monitoring and optimization.
- **Automated Scaling**: Karpenter for dynamic node provisioning.

## Prerequisites

To use this project, you need the following tools installed and configured:

1. **Terraform** (>= 1.0): For provisioning infrastructure.
2. **AWS CLI**: For interacting with AWS services.
3. **kubectl**: For managing Kubernetes clusters.
4. **Helm** (v3): For deploying Kubernetes applications.
5. **Python**: For running distributed training scripts.

## Getting Started

### 1. **Set Up AWS CLI**
   - Install the AWS CLI: [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
   - Configure your AWS credentials:
     ```bash
     aws configure
     ```

### 2. **Provision the Infrastructure**
   - Navigate to the `infra/eks/` directory.
   - Initialize Terraform:
     ```bash
     terraform init
     ```
   - Apply the Terraform configuration:
     ```bash
     terraform apply
     ```

### 3. **Configure kubectl**
   - Update your `kubectl` configuration to connect to the EKS cluster:
     ```bash
     aws eks --region <region> update-kubeconfig --name <cluster-name>
     ```

### 4. **Deploy Distributed Training Jobs**
   - Navigate to the `examples/` directory and choose the framework you want to use (e.g., Ray, Torchrun, MPI, Training Operator, or Volcano Scheduler).
   - Follow the README in each subdirectory to deploy and run distributed training jobs.

## Example Workflows

### Running a Ray Job
1. Navigate to `examples/ray/`.
2. Follow the instructions in the `README.md` to deploy a Ray cluster and submit a job.

### Running an MPI Job with Volcano Scheduler
1. Navigate to `examples/volcano_scheduler/`.
2. Update the `multinode_ddp_volcano_mpi_job.yaml` manifest with your training script.
3. Submit the job:
   ```bash
   kubectl apply -f multinode_ddp_volcano_mpi_job.yaml
   ```

### Running a Training Operator Job
1. Navigate to `examples/training_operator/`.
2. Update the job manifest (e.g., `multinode_ddp_pytorch_job.yaml`) with your training script.
3. Submit the job:
   ```bash
   kubectl apply -f multinode_ddp_pytorch_job.yaml
   ```

## Monitoring and Debugging

- **Grafana Dashboard**:
  ```bash
  kubectl port-forward svc/kube-prometheus-stack-grafana 8080:80 -n kube-prometheus-stack
  ```
  Access at `http://localhost:8080`.

- **Kubernetes Dashboard**:
  ```bash
  kubectl port-forward service/kubernetes-dashboard-kong-proxy -n kubernetes-dashboard 8443:443
  ```
  Access at `https://localhost:8443`.

- **Job Status**:
  Use `kubectl get jobs` or `kubectl get pods` to monitor the status of your jobs.

## Cleanup

To destroy the infrastructure and avoid unnecessary costs:
```bash
terraform destroy
```

## References

- **Terraform Documentation**: [https://www.terraform.io/docs/](https://www.terraform.io/docs/)
- **AWS EKS Documentation**: [https://docs.aws.amazon.com/eks/](https://docs.aws.amazon.com/eks/)
- **Kubernetes Documentation**: [https://kubernetes.io/docs/](https://kubernetes.io/docs/)
- **Ray Documentation**: [https://docs.ray.io/](https://docs.ray.io/)
- **PyTorch Distributed Training**: [https://pytorch.org/tutorials/intermediate/ddp_tutorial.html](https://pytorch.org/tutorials/intermediate/ddp_tutorial.html)
