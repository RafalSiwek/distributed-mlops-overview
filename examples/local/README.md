# PyTorch Distributed Training on Local Machines

This repository contains PyTorch training scripts for running distributed experiments on local machines with varying hardware configurations. The scripts are designed for:

1. **Single-node CPU-based training** (`singlenode.py`)
2. **Single-node single-GPU training** (`singlenode_gpu.py`)
3. **Single-node multi-GPU training using Distributed Data Parallel (DDP)** (`singlenode_multigpu_ddp.py`)

To run these experiments, you need to provision the appropriate EC2 instances using Terraform. The Terraform configuration is located in the [`infra/ec2/`](../../infra/ec2/) directory.

## Directory Structure

```
.
├── README.md
├── singlenode.py
├── singlenode_gpu.py
└── singlenode_multigpu_ddp.py
```

## Prerequisites

1. **Provision EC2 Instances**:
   - Navigate to the [`infra/ec2/`](../../infra/ec2/) directory.
   - Update the Terraform variables to launch the appropriate instance types:
     - For CPU-based training: Use a general-purpose instance (`t3.xlarge`).
     - For single-GPU training: Use a GPU-enabled instance ( `g4dn.xlarge` or `g4ad.xlarge`).
     - For multi-GPU training: Use a multi-GPU instance (e.g., `g4dn.8xlarge` or `g4ad.8xlarge`).
   - Provision the instances using Terraform:
     ```bash
     terraform init
     terraform apply
     ```

2. **Access and Configure Instances**:
   - Follow the instructions in the [`infra/ec2/README.md`](../../infra/ec2/README.md) file to access and configure the EC2 instances.
   - Ensure that PyTorch and its dependencies are installed on the instances. You can install PyTorch following the [official guide](https://pytorch.org/get-started/locally/)

## Running the Training Scripts

### 1. Single-Node CPU Training (`singlenode.py`)
This script is designed for training on a single-node CPU-based machine.

- **Command**:
  ```bash
  python singlenode.py <arguments>
  ```
- **Arguments**:
  - Refer to the `singlenode.py` file for the required arguments.

### 2. Single-Node Single-GPU Training (`singlenode_gpu.py`)
This script is designed for training on a single-node machine with a single GPU.

- **Command**:
  ```bash
  python singlenode_gpu.py <arguments>
  ```
- **Arguments**:
  - Refer to the `singlenode_gpu.py` file for the required arguments.

### 3. Single-Node Multi-GPU Training (`singlenode_multigpu_ddp.py`)
This script is designed for training on a single-node machine with multiple GPUs using PyTorch's Distributed Data Parallel (DDP).

- **Command**:
  ```bash
  torchrun --standalone --nproc-per-node=gpu singlenode_multigpu_ddp.py <arguments>
  ```
- **Arguments**:
  - Refer to the `singlenode_multigpu_ddp.py` file for the required arguments.

## Example Commands

### Single-Node CPU Training
```bash
python singlenode.py 10 10 --batch-size 32 
```

### Single-Node Single-GPU Training
```bash
python singlenode_gpu.py 10 10 --batch-size 32 
```

### Single-Node Multi-GPU Training
```bash
torchrun --standalone --nproc-per-node=gpu singlenode_multigpu_ddp.py 10 10 --batch-size 32 
```

## Cleanup

After completing your experiments, ensure you clean up the EC2 instances to avoid unnecessary costs:

1. Navigate to the [`infra/ec2/`](../../infra/ec2/) directory.
2. Run the following command to destroy the provisioned resources:
   ```bash
   terraform destroy
   ```

## Additional Notes

- Ensure that the instance types you provision match the hardware requirements of your training scripts.
- For multi-GPU training, ensure that the instance has the required number of GPUs and that the `torchrun` command is used to leverage all available GPUs.
- Refer to the PyTorch documentation for more details on distributed training: [PyTorch Distributed Training](https://pytorch.org/tutorials/intermediate/ddp_tutorial.html).