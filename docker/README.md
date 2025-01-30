# Docker Build Recipes

This directory contains Dockerfile recipes and associated build scripts for creating containers optimized for different AWS EC2 instance types, specifically targeting distributed deep learning workloads.

## Directory Structure

```
docker/
├── g4ad_rocm_build/     # ROCm-based build for AMD GPUs (G4ad instances)
├── g4dn_cuda_build/     # CUDA-based build for NVIDIA GPUs (G4dn instances)
└── standard_mpi_runner/ # Base MPI runner without GPU support
```

## Build Configurations

### G4ad ROCm Build
- ROCm 6.2.2 optimized for AMD GPUs
- MPI, UCX, and UCC for distributed communication
- Ready for building PyTorch with ROCm support
- Target: AWS G4ad instances

### G4dn CUDA Build
- CUDA 12.4 optimized for NVIDIA GPUs
- MPI, UCX, and UCC for distributed communication
- Ready for building PyTorch with CUDA support
- Target: AWS G4dn instances

### Standard MPI Runner
- Base container with MPI, UCX, and UCC
- No GPU dependencies
- Optional PyTorch installation from official PyTorch pip repository
- Suitable for launching distributed workloads

## Building Images Locally

To build the images locally, navigate to the respective directory and run the docker build command:

```bash
# For ROCm build
cd g4ad_rocm_build
docker build -t rocm_pytorch:latest .

# For CUDA build
cd g4dn_cuda_build
docker build -t cuda_pytorch:latest .

# For standard MPI runner
cd standard_mpi_runner
docker build -t mpi_runner:latest .
```

## Pre-built Images

Pre-built images are available on Docker Hub under the rafalsiwek repository:

### With PyTorch 2.5.1
```bash
docker pull rafalsiwek/rocm_pytorch:2.5.1
docker pull rafalsiwek/cuda_pytorch:2.5.1
docker pull rafalsiwek/mpi_runner:2.5.1
```

### Base Images (without PyTorch)
```bash
docker pull rafalsiwek/rocm_base:latest
docker pull rafalsiwek/cuda_base:latest
docker pull rafalsiwek/mpi_runner:latest
```

## Note
Each subdirectory contains its own README with specific build instructions and customization options. Please refer to those for detailed information about build arguments and environment configurations.