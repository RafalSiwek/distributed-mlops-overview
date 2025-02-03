# Low-Level All-Reduce Implementation with NCCL and RCCL

This project demonstrates a two-node low-level all-reduce implementation using **NCCL** (NVIDIA) and **RCCL** (AMD) with MPI for multi-node communication.

---

## Prerequisites

### Instance Provisioning
1. Provision EC2 instances using the [terraform variables in `infra/ec2/`](../../../infra/ec2/):
   - **NVIDIA**: Use `g4dn` instances (e.g., `g4dn.xlarge`).
   - **AMD**: Use `g4ad` instances (e.g., `g4ad.xlarge`).

### Software Setup
- **NVIDIA**:
  - Install CUDA and NCCL ([official guide](https://docs.nvidia.com/deeplearning/nccl/install-guide/index.html)).
  - *Optional Docker*: `rafalsiwek/g4dn_distributed_ml:1.0_base` (CUDA 12.4).

- **AMD**:
  - Install ROCm, RCCL, and HIP ([HIP install guide](https://rocm.docs.amd.com/projects/HIP/en/latest/install/install.html)).
  - *Optional Docker*: `rafalsiwek/g4ad_distributed_ml:1.0_base` (ROCm 6.2.2).

- **MPI Launcher**:
  - Use an instance with OpenMPI or `rafalsiwek/opmpi_ucx_simple:1.0_base`.
  - Configure **passwordless SSH** between nodes.
  - Ensure all nodes have the compiled `main` binary in the same directory.

---

## Compilation
Before running the implementations have to be compiled into executables

### NVIDIA (NCCL)
```bash
nvcc -o main nccl.cpp -lmpi -lnccl
```

### AMD (RCCL)
```bash
hipcc -o main rccl.cpp -lmpi -lrccl
```

---

## Execution

Run the following command on the MPI launcher node:
```bash
mpirun --allow-run-as-root -np 2 -H <node_0_ip>,<node_1_ip> -mca btl_tcp_if_include ens5 ./main
```

- Replace `<node_0_ip>` and `<node_1_ip>` with your node IPs.
- Adjust `ens5` to match your instance’s network interface (e.g., `eth0`).

---

## Expected Output
```
Rank 0 received AllReduce result: X
Rank 1 received AllReduce result: X
```

---

## Notes
- **Docker**: The provided images are unofficial and target unsupported GPUs (e.g., AMD Radeon V520 on `g4ad`).
- **Network Interface**: Verify with `ip addr` (common interfaces: `ens5`, `eth0`).
