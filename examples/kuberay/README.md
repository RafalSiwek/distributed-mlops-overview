# PyTorch Distributed Data Parallel (DDP) with Ray on Kubernetes

This repository provides an example of running a PyTorch Distributed Data Parallel (DDP) job on a Ray cluster provisioned on Kubernetes (K8s) using KubeRay version 1.2.2. The Ray cluster is deployed on an AWS EKS infrastructure, which can be provisioned using Terraform.

## Directory Structure

```
.
├── README.md
├── pytorch_ray_submit.py
├── ray_cluster_config_values.yaml
└── scripts
    └── multinode_ddp.py
```

## Prerequisites

1. **Kubectl and Helm Installation and Configuration**:
   - **kubectl**: Install `kubectl` by following the official [Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
   - **helm**: Install `helm` by following the official [Helm documentation](https://helm.sh/docs/intro/install/).
   - **Configure kubectl**: Ensure `kubectl` is configured to interact with your EKS cluster. You can configure it using the AWS CLI:
     ```bash
     aws eks --region <region> update-kubeconfig --name <cluster-name>
     ```

2. **AWS EKS Infrastructure**:
   - Ensure the AWS EKS infrastructure is provisioned using Terraform. The Terraform configuration is located in the [`infra/eks/`](../../infra/eks/) directory.
   - Set the `ray_cluster_enabled` variable to `true` in the Terraform configuration to enable the Ray cluster.

## Deploying the Ray Cluster

1. **Deploy the Ray Cluster using Helm**:
   Run the following command to deploy the Ray cluster using Helm:
   ```bash
   helm upgrade --install ray-cluster kuberay/ray-cluster --version 1.1.0 --wait -f ray_cluster_config_values.yaml -n ray-cluster --create-namespace
   ```

2. **Verify Ray Cluster Pods**:
   Ensure the Ray cluster pods are running in the `ray-cluster` namespace:
   ```bash
   kubectl get pods -n ray-cluster
   ```
   Expected output:
   ```
   NAME                                           READY   STATUS    RESTARTS   AGE
   ray-cluster-kuberay-head-xxxxx                 1/1     Running   0          2m
   ```

3. **Access the Ray Cluster Dashboard**:
   To access the Ray cluster dashboard, use `kubectl port-forward`:
   ```bash
   kubectl port-forward service/ray-cluster-kuberay-head-svc -n ray-cluster 8266:8265
   ```
   The Ray dashboard will be accessible at `http://localhost:8266`.

## Running the PyTorch DDP Job

1. **Submit the Ray Job**:
   Run the following command to submit the PyTorch DDP job to the Ray cluster:
   ```bash
   python pytorch_ray_submit.py
   ```

## Cleanup

1. **Delete the Ray Cluster**:
   To clean up the Ray cluster, run the following command:
   ```bash
   helm delete ray-cluster -n ray-cluster
   ```

## Additional Notes

- Ensure that the `ray_cluster_config_values.yaml` file is correctly configured for your specific use case.
- The `pytorch_ray_submit.py` script contains the logic to submit the PyTorch DDP job to the Ray cluster. Modify this script as needed for your specific job requirements.
- The `multinode_ddp.py` script in the `scripts` directory contains the PyTorch DDP training logic. Ensure this script is correctly configured for your training job.

For any issues or further assistance, please refer to the [Ray documentation](https://docs.ray.io/en/latest/) or the [KubeRay documentation](https://ray-project.github.io/kuberay/).