# MPI-Based Distributed Training with PyTorch

This directory contains MPI-based PyTorch training scripts for running distributed experiments across multiple nodes. The scripts are designed for:

1. **Multi-node CPU-based training** (`multinode_ddp_mpi.py`)
2. **Multi-node GPU-based training** (`multinode_ddp_mpi_gpu.py`)

To run these experiments, you need to provision a multi-node EC2 cluster using Terraform. The Terraform configuration is located in the [`infra/ec2/`](../../infra/ec2/) directory.

## Directory Structure

```
.
├── README.md
├── multinode_ddp_mpi.py
└── multinode_ddp_mpi_gpu.py
```

## Prerequisites

### 1. Provision EC2 Instances
- Navigate to the [`infra/ec2/`](../../infra/ec2/) directory.
- Set the Terraform variable `multinode_mpi` to `true` to provision the required instances:
  - **1x Launcher**: `t3.micro`
  - **2x Workers**: `t3.xlarge` (for CPU-based training) or GPU-enabled instances (e.g., `g4dn.xlarge` and `g4ad.xlarge` for GPU-based training).
- Provision the instances using Terraform:
  ```bash
  terraform init
  terraform apply
  ```

### 2. Install Dependencies
- **OpenMPI**: Install a compatible version of OpenMPI on all nodes. Follow the [OpenMPI installation guide](https://www.open-mpi.org/faq/?category=building#easy-build).
- **PyTorch**: Install PyTorch on the worker nodes by following the [PyTorch installation guide](https://pytorch.org/get-started/locally/).
- **Passwordless SSH**: Set up passwordless SSH between the launcher and worker nodes. Follow the [OpenMPI SSH guide](https://docs.open-mpi.org/en/v5.0.x/launching-apps/ssh.html).

### 3. Docker Setup (Optional)
You can use pre-built Docker images to simplify the setup:
- **Launcher Image**: `rafalsiwek/opmpi_ucx_simple:1.0_base`
- **Worker Image**: `rafalsiwek/opmpi_ucx_simple:1.0_pytorch_2.5.1` (for CPU-based training) or `rafalsiwek/g4ad_distributed_ml:1.0_pytorch_2.5.1` and `rafalsiwek/g4dn_distributed_ml:1.0_pytorch_2.5.1` (for GPU-based NVIDIA or AMD training).

#### Steps to Configure Docker Containers:
1. **Generate SSH Key in Launcher Container**:
   ```bash
   ssh-keygen -t rsa
   ```

2. **Copy Public Key to Worker Containers**:
   - Paste the public key (`~/.ssh/id_rsa.pub`) into the `~/.ssh/authorized_keys` file on each worker container.

3. **Update SSH Daemon Port**:
   - Edit the SSH daemon configuration in each worker container:
     ```bash
     vi /etc/ssh/sshd_config
     ```
   - Change the port to a value not used by the host.

4. **Update SSH Client Configuration in Launcher Container**:
   - Edit the SSH client configuration:
     ```bash
     vi /etc/ssh/ssh_config
     ```
   - Update the port to match the worker containers.

5. **Start SSH Server in Worker Containers**:
   ```bash
   /usr/sbin/sshd -D
   ```

6. **Run Containers with Host Networking**:
   Use the `--network=host` flag to run the containers interactively:
   ```bash
   docker run -it --network=host <image_name>
   ```

7. **Copy Code to Containers**:
   Ensure the training scripts (`multinode_ddp_mpi.py` and `multinode_ddp_mpi_gpu.py`) are available in the same directory on all containers.

## Running the MPI Job

### 1. CPU-Based Training (`multinode_ddp_mpi.py`)
Run the following command from the launcher node:
```bash
mpirun --allow-run-as-root -np 2 -H <worker_0_ip_addr>,<worker_1_ip_addr> -x MASTER_ADDR=<worker_0_ip_addr> -x MASTER_PORT=1234 python3 /test/multinode_ddp_mpi.py <parameters>
```

### 2. GPU-Based Training (`multinode_ddp_mpi_gpu.py`)
Run the following command from the launcher node:
```bash
mpirun --allow-run-as-root -np 2 -H <worker_0_ip_addr>,<worker_1_ip_addr> -x MASTER_ADDR=<worker_0_ip_addr> -x MASTER_PORT=1234 /opt/conda/envs/py_3.12/bin/python /test/multinode_ddp_mpi_gpu.py <parameters>
```

### 3. GPU-Based Training with MPI Backend
For advanced configurations using the MPI backend, run:
```bash
mpirun --allow-run-as-root -np 2 -H <worker_0_ip_addr>,<worker_1_ip_addr> -mca pml ucx -mca coll_ucc_enable 1 -mca coll_ucc_priority 100 -x UCX_ROCM_COPY_D2H_THRESH=0 -x UCX_ROCM_COPY_H2D_THRESH=0 -x UCC_EC_ROCM_REDUCE_HOST_LIMIT=0 -x UCC_EC_ROCM_COPY_HOST_LIMIT=0 -x OMPI_MCA_mpi_accelerator_rocm_memcpyD2H_limit=0 -x OMPI_MCA_mpi_accelerator_rocm_memcpyH2D_limit=0 /opt/conda/envs/py_3.12/bin/python /test/multinode_ddp_mpi_gpu.py <parameters>
```

## Example Commands

### CPU-Based Training
```bash
mpirun --allow-run-as-root -np 2 -H 10.0.0.1,10.0.0.2 -x MASTER_ADDR=10.0.0.1 -x MASTER_PORT=1234 python3 /test/multinode_ddp_mpi.py 1000 1000
```

### GPU-Based Training
```bash
mpirun --allow-run-as-root -np 2 -H 10.0.0.1,10.0.0.2 -x MASTER_ADDR=10.0.0.1 -x MASTER_PORT=1234 /opt/conda/envs/py_3.12/bin/python /test/multinode_ddp_mpi_gpu.py 1000 1000
```

## Cleanup

After completing your experiments, destroy the provisioned resources to avoid unnecessary costs:
1. Navigate to the [`infra/ec2/`](../../infra/ec2/) directory.
2. Run the following command:
   ```bash
   terraform destroy
   ```

## Additional Notes

- Ensure the IP addresses of the worker nodes are correctly specified in the `mpirun` command.
- For GPU-based training, ensure the worker nodes have the required GPU drivers and libraries installed.
- Refer to the [PyTorch Distributed Training documentation](https://pytorch.org/tutorials/intermediate/ddp_tutorial.html) for more details on distributed training.