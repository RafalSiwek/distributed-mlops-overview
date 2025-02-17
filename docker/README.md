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

## Building PyTorch 
When using MPI backend or running the code on AWS G4ad instances with unsupported AMD gfx1011 GPU, PyTorch has to be built from source:

1. Download PyTorch repo and build it for GFX1011:

    Clone the v2.5.1 version of the PyTorch repo (latest main at this moment)

    ```bash
    cd ~
    git clone https://github.com/pytorch/pytorch.git -b v2.5.1
    cd pytorch
    git submodule update --init --recursive
    ```
    Clone the latest vision plugin repo for PyTorch
    ```bash
    git clone https://github.com/pytorch/vision.git
    ```

2. Building PyTorch from source will take a long time (>8h on the g4ad-xlarge machine), so let's build it using the Docker image in the container detached mode, sharing the volume

    ```bash
    docker run -it --cap-add=SYS_PTRACE  --user root --security-opt  \
    seccomp=unconfined --device=/dev/kfd --device=/dev/dri \
    --group-add video --ipc=host --shm-size 8G \
    -v ~/pytorch:/pytorch -d -w /pytorch --name pytorch_build_torch rafalsiwek/g4ad_distributed_ml:1.0_base  bash
    ```
    for AMD GPU G4ad,
    ```bash
    docker run -it --cap-add=SYS_PTRACE  --user root --security-opt  \
    seccomp=unconfined --gpus all \
    --group-add video --ipc=host --shm-size 8G \
    -v ~/pytorch:/pytorch -d -w /pytorch --name pytorch_build_torch rafalsiwek/g4dn_distributed_ml:1.0_base  bash
    ``` 
    For NVIDIA G4dn

3. Build PyTorch:
    First PyTorch source code needs to be patched to support building with UCC and MPI and the given AWS G4 instance GPU archs:
    ```bash
    git apply pytorch_patches/pytorch_mpi_aws_g4.patch
    ```
    For AMD GPUs first the code needs to be `hipified`:
    G4a:
    ```bash
    python tools/amd_build/build_amd.py
    ```

    Next, regardless the device:
    ```bash
    python setup.py bdist_wheel
    ```

    This will build and post the compiled PyTorch package into `~/pytorch/dist/torch*.wheel`

4. To build the Torchaudio and Torchvision packages, consecutively, run:

    ```bash
    docker run -it --cap-add=SYS_PTRACE  --user root --security-opt  \
    seccomp=unconfined --device=/dev/kfd --device=/dev/dri \
    --group-add video --ipc=host --shm-size 8G \
    -v ~/pytorch:/pytorch -e PYTORCH_ROCM_ARCH=gfx1011 -d -w /pytorch/audio --name pytorch_build_audio rafalsiwek/g4ad_distributed_ml:1.0_pytorch_2.5.1 python setup.py bdist_wheel
    ```
    This will build and post the compiled Torchaudio package into `~/pytorch/audio/dist/torch*.wheel`

    ```bash
    docker run -it --cap-add=SYS_PTRACE  --user root --security-opt  \
    seccomp=unconfined --device=/dev/kfd --device=/dev/dri \
    --group-add video --ipc=host --shm-size 8G \
    -v ~/pytorch:/pytorch -e PYTORCH_ROCM_ARCH=gfx1011 -d -w /pytorch/vision --name pytorch_build_vision rafalsiwek/g4ad_distributed_ml:1.0_pytorch_2.5.1 python setup.py bdist_wheel
    ```
    This will build and post the compiled Torchvision package into `~/pytorch/audio/dist/torch*.wheel`

**With these packages build, you can prepare and push the GFX1011-ROCm-PyTorch enabled Docker image to your registry by following the instructions under step 3.**

## Pre-built Images

Pre-built images are available on Docker Hub under the rafalsiwek repository:

### With PyTorch 2.5.1
```bash
docker pull rafalsiwek/g4ad_distributed_ml:1.0_pytorch_2.5.1
docker pull rafalsiwek/g4dn_distributed_ml:1.0_pytorch_2.5.1
docker pull rafalsiwek/opmpi_ucx_simple:1.0_pytorch_2.5.1
```

### Base Images (without PyTorch)
```bash
docker pull rafalsiwek/g4ad_distributed_ml:1.0_base
docker pull rafalsiwek/g4dn_distributed_ml:1.0_base
docker pull rafalsiwek/opmpi_ucx_simple:1.0_base
```

## Note
Each subdirectory contains its own README with specific build instructions and customization options. Please refer to those for detailed information about build arguments and environment configurations.
