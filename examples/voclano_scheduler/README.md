# Running Volcano Jobs on Kubernetes

This repository provides examples of running distributed PyTorch training jobs on Kubernetes using the **Volcano Scheduler**. The directory contains job manifests and scripts for multi-node distributed training with MPI.

## Directory Structure

```
.
├── README.md
├── multinode_ddp_volcano_mpi_job.yaml
└── scripts
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
  - `volcano_scheduler_enabled = true`
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

### 5. **Install Volcano Scheduler**
- Ensure the Volcano Scheduler is installed and running. This is typically handled by the Terraform configuration when `volcano_scheduler_enabled` is set to `true`.

## Running Volcano Jobs

### 1. **Prepare the Job Manifests**
- The job manifest (`multinode_ddp_volcano_mpi_job.yaml`) defines the training job.
- The training scripts (`pytorch_multinode_ddp_mpi.py` and `pytorch_multinode_ddp_mpi_gpu.py`) are loaded into the pods via a **ConfigMap**.
- Update the `main.py` field in the ConfigMap section of the manifest with the content of the corresponding script:
  ```yaml
  data:
    main.py: |
      # Paste the content of the script here
  ```

### 2. **Submit the Job**
- Submit the job using `kubectl`:
  ```bash
  kubectl apply -f multinode_ddp_volcano_mpi_job.yaml
  ```

### 3. **Monitor Job Status**
- Check the status of the job:
  ```bash
  kubectl get jobs.batch.volcano.sh -n distributed-training
  ```

### 4. **View Logs**
- To view logs for a specific pod:
  ```bash
  kubectl logs <pod-name> -n distributed-training
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

### Submit a Volcano Job
```bash
kubectl apply -f multinode_ddp_volcano_mpi_job.yaml
```

### Monitor Job Status
```bash
kubectl get jobs.batch.volcano.sh -n distributed-training
```

## Cleanup

To delete the job and free up resources:
```bash
kubectl delete -f multinode_ddp_volcano_mpi_job.yaml
```

## References

- **Volcano Scheduler Documentation**: [https://volcano.sh/docs/](https://volcano.sh/docs/)
- **Training Operator Documentation**: [https://www.kubeflow.org/docs/components/training/](https://www.kubeflow.org/docs/components/training/)
- **MPI Operator Documentation**: [https://www.kubeflow.org/docs/components/training/mpi/](https://www.kubeflow.org/docs/components/training/mpi/)
- **Kubernetes Documentation**: [https://kubernetes.io/docs/home/](https://kubernetes.io/docs/home/)

For further assistance, consult the [Volcano documentation](https://volcano.sh/docs/) or the [Kubernetes community forums](https://discuss.kubernetes.io/).