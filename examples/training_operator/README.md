# Running Training Operator Jobs on Kubernetes

This repository provides examples of running distributed PyTorch training jobs on Kubernetes using the **Training Operator** and **MPI Operator**. The directory contains job manifests and scripts for multi-node distributed training.

## Directory Structure

```
.
├── README.md
├── multinode_ddp_mpi_job.yaml
├── multinode_ddp_pytorch_job.yaml
└── scripts
    ├── pytorch_multinode_ddp.py
    ├── pytorch_multinode_ddp_gpu.py
    ├── pytorch_multinode_ddp_mpi.py
    └── pytorch_multinode_ddp_mpi_gpu.py
```

## Prerequisites

### 1. **Install and Configure `kubectl`**
- Install `kubectl` by following the official [Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- Configure `kubectl` to connect to your EKS cluster:
  ```bash
  aws eks --region <region> update-kubeconfig --name <cluster-name>
  ```

### 2. **Provision EKS Infrastructure**
- Navigate to the [`infra/eks/`](../../infra/eks/) directory.
- Enable the following Terraform flags:
  - `training_job_multinode_enabled = true`
  - Optionally, enable `training_job_multinode_gpu_enabled = true` for GPU support.
- Provision the infrastructure:
  ```bash
  terraform init
  terraform apply
  ```

### 3. **Verify GPU Operators**
- Ensure all pods in the `amd-gpu-operator` and `nvidia-gpu-operator` namespaces are running:
  ```bash
  kubectl get pods -n amd-gpu-operator
  kubectl get pods -n nvidia-gpu-operator
  ```

### 4. **Install Training and MPI Operators**
- Install the **Training Operator**:
  ```bash
  kubectl apply --server-side -k "github.com/kubeflow/training-operator.git/manifests/overlays/standalone?ref=v1.8.1"
  ```
- Install the **MPI Operator**:
  ```bash
  kubectl apply --server-side -k "github.com/kubeflow/mpi-operator.git/manifests/overlays/standalone?ref=v0.6.0"
  ```
- Verify that all pods in the `kubeflow` and `mpi-operator` namespaces are running:
  ```bash
  kubectl get pods -n kubeflow
  kubectl get pods -n mpi-operator
  ```

## Running Training Jobs

### 1. **Prepare the Job Manifests**
- The job manifests (`multinode_ddp_mpi_job.yaml` and `multinode_ddp_pytorch_job.yaml`) define the training jobs.
- The training scripts (`pytorch_multinode_ddp.py`, `pytorch_multinode_ddp_gpu.py`, etc.) are loaded into the pods via a **ConfigMap**.
- Update the `main.py` field in the ConfigMap section of the manifest with the content of the corresponding script:
  ```yaml
  data:
    main.py: |
      # Paste the content of the script here
  ```

### 2. **Submit the Job**
- Submit the job using `kubectl`:
  - For PyTorch jobs:
    ```bash
    kubectl apply -f multinode_ddp_pytorch_job.yaml
    ```
  - For MPI jobs:
    ```bash
    kubectl apply -f multinode_ddp_mpi_job.yaml
    ```

### 3. **Monitor Job Status**
- Check the status of the jobs:
  - For PyTorch jobs:
    ```bash
    kubectl get pytorchjobs -n training-operator
    ```
  - For MPI jobs:
    ```bash
    kubectl get mpijobs -n training-operator
    ```

### 4. **View Logs**
- To view logs for a specific pod:
  ```bash
  kubectl logs <pod-name> -n training-operator
  ```

## Adjusting Resource Quota for GPU Jobs

For GPU-based jobs, ensure the resource quota is adjusted to allocate GPU resources. Update the `resources` section in the job manifest:
```yaml
resources:
  limits:
    nvidia.com/gpu: 1  # Adjust based on the number of GPUs required
  requests:
    nvidia.com/gpu: 1
```
And `tolerations`, as the [Karpenter provider sets specific taints](../../infra/eks/nodepools.tf):
```yaml
tolerations:
  - effect: NoSchedule
    key: nvidia.com/gpu
    operator: Exists
  - effect: NoSchedule
    key: training-operator-job-gpu
```

## Example Commands

### Submit a PyTorch Job

```bash
kubectl apply -f multinode_ddp_pytorch_job.yaml
```

### Submit an MPI Job
```bash
kubectl apply -f multinode_ddp_mpi_job.yaml
```

### Monitor Job Status
```bash
kubectl get pytorchjobs -n training-operator
kubectl get mpijobs -n training-operator
```

## Cleanup

To delete the jobs and free up resources:
```bash
kubectl delete -f multinode_ddp_pytorch_job.yaml
kubectl delete -f multinode_ddp_mpi_job.yaml
```

## References

- **Training Operator Documentation**: [https://www.kubeflow.org/docs/components/training/](https://www.kubeflow.org/docs/components/training/)
- **MPI Operator Documentation**: [https://www.kubeflow.org/docs/components/training/mpi/](https://www.kubeflow.org/docs/components/training/mpi/)
- **Kubernetes Documentation**: [https://kubernetes.io/docs/home/](https://kubernetes.io/docs/home/)

For further assistance, consult the [Kubeflow documentation](https://www.kubeflow.org/docs/) or the [Kubernetes community forums](https://discuss.kubernetes.io/).