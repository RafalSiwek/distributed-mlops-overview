# Torchrun-Based Distributed Training with PyTorch

This directory contains PyTorch training scripts for running distributed experiments using `torchrun`. The scripts are designed for:

1. **Multi-node CPU-based training** (`multinode_ddp.py`)
2. **Multi-node GPU-based training** (`multinode_gpu_ddp.py`)
3. **Multi-node MPI-based CPU training** (`pytorch_multinode_ddp_mpi.py`)
4. **Multi-node MPI-based GPU training** (`pytorch_multinode_ddp_mpi_gpu.py`)

To run these experiments, you need to provision a multi-node cluster and ensure all nodes have PyTorch installed. Pre-built Docker images are available to simplify the setup.

## Directory Structure

```
.
├── multinode_ddp.py
├── multinode_gpu_ddp.py
├── pytorch_multinode_ddp_mpi.py
└── pytorch_multinode_ddp_mpi_gpu.py
```

## Prerequisites

### 1. Provision EC2 Instances
- Navigate to the [`infra/ec2/`](../../infra/ec2/) directory.
- Set the Terraform variable `multinode_torchrun` to `true` to provision the required instances:
  - **CPU-based training**: Use general-purpose instances (e.g., `t3.xlarge`).
  - **GPU-based training**: Use GPU-enabled instances (e.g., `g4dn.xlarge` for NVIDIA GPUs or `g4ad.xlarge` for AMD GPUs).
- Provision the instances using Terraform:
  ```bash
  terraform init
  terraform apply
  ```

### 2. Install Dependencies
- **PyTorch**: Install PyTorch on all nodes by following the [PyTorch installation guide](https://pytorch.org/get-started/locally/).
- **Docker (Optional)**: Use pre-built Docker images to simplify the setup:
  - **CPU-based training**: `rafalsiwek/opmpi_ucx_simple:1.0_pytorch_2.5.1`
  - **AMD GPU-based training**: `rafalsiwek/g4ad_distributed_ml:1.0_pytorch_2.5.1`
  - **NVIDIA GPU-based training**: `rafalsiwek/g4dn_distributed_ml:1.0_pytorch_2.5.1`

#### Steps to Configure Docker Containers:
1. **Run Containers with Host Networking**:
   Use the `--network=host` flag to run the containers interactively:
   ```bash
   docker run -it --network=host <image_name>
   ```

2. **Copy Code to Containers**:
   Ensure the training scripts (`multinode_ddp.py`, `multinode_gpu_ddp.py`, etc.) are available in the same directory on all containers.

## Running the Distributed Training Job

### Command to Launch Distributed Training
The command to launch distributed training using `torchrun` is the same regardless of the device configuration (CPU or GPU):

```bash
torchrun --nproc-per-node=1 --nnodes=<number_of_nodes> --node-rank=<rank_of_node> --rdzv-id=456 --rdzv-backend=c10d --rdzv-endpoint=<rank_0_node>:29603 <code>.py <parameters>
```

### Parameters:
- `--nproc-per-node=1`: Number of processes per node.
- `--nnodes=<number_of_nodes>`: Total number of nodes in the cluster.
- `--node-rank=<rank_of_node>`: Rank of the current node (starting from 0).
- `--rdzv-id=456`: Unique ID for the rendezvous process.
- `--rdzv-backend=c10d`: Rendezvous backend (use `c10d` for PyTorch's native backend).
- `--rdzv-endpoint=<rank_0_node>:29603`: Endpoint of the rank 0 node (e.g., `10.0.0.1:29603`).
- `<code>.py`: The script to run (e.g., `multinode_ddp.py`).
- `<parameters>`: Script-specific parameters.

### Example Commands

#### CPU-Based Training (`multinode_ddp.py`)
```bash
torchrun --nproc-per-node=1 --nnodes=2 --node-rank=0 --rdzv-id=456 --rdzv-backend=c10d --rdzv-endpoint=10.0.0.1:29603 multinode_ddp.py 1000 1000
```

#### GPU-Based Training (`multinode_gpu_ddp.py`)
```bash
torchrun --nproc-per-node=1 --nnodes=2 --node-rank=0 --rdzv-id=456 --rdzv-backend=c10d --rdzv-endpoint=10.0.0.1:29603 multinode_gpu_ddp.py 1000 1000
```

#### MPI-Based CPU Training (`pytorch_multinode_ddp_mpi.py`)
```bash
torchrun --nproc-per-node=1 --nnodes=2 --node-rank=0 --rdzv-id=456 --rdzv-backend=c10d --rdzv-endpoint=10.0.0.1:29603 pytorch_multinode_ddp_mpi.py 1000 1000
```

#### MPI-Based GPU Training (`pytorch_multinode_ddp_mpi_gpu.py`)
```bash
torchrun --nproc-per-node=1 --nnodes=2 --node-rank=0 --rdzv-id=456 --rdzv-backend=c10d --rdzv-endpoint=10.0.0.1:29603 pytorch_multinode_ddp_mpi_gpu.py 1000 1000
```

## Cleanup

After completing your experiments, destroy the provisioned resources to avoid unnecessary costs:
1. Navigate to the [`infra/ec2/`](../../infra/ec2/) directory.
2. Run the following command:
   ```bash
   terraform destroy
   ```

## Additional Notes

- Ensure the IP addresses of the nodes are correctly specified in the `--rdzv-endpoint` parameter.
- For GPU-based training, ensure the worker nodes have the required GPU drivers and libraries installed.
- Refer to the [PyTorch Distributed Training documentation](https://pytorch.org/tutorials/intermediate/ddp_tutorial.html) for more details on distributed training.