FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

# Set AMD gpu targets to build for
ENV PYTORCH_ROCM_ARCH=gfx1011
ENV ROCM_ARCH=${PYTORCH_ROCM_ARCH}

# Install common dependencies (so that this step can be cached separately)
COPY ./scripts/install_base.sh install_base.sh
RUN bash ./install_base.sh && rm install_base.sh

# Install conda and other packages (e.g., numpy, pytest)
ENV ANACONDA_PYTHON_VERSION=3.12
ENV PATH /opt/conda/envs/py_3.12/bin:/opt/conda/bin:$PATH
COPY ./scripts/requirements.txt /opt/conda/requirements.txt
COPY ./scripts/install_conda.sh install_conda.sh
COPY ./scripts/common_utils.sh common_utils.sh
RUN bash ./install_conda.sh && rm install_conda.sh common_utils.sh /opt/conda/requirements.txt

# Install gcc
ENV GCC_VERSION=9
COPY ./scripts/install_gcc.sh install_gcc.sh
RUN bash ./install_gcc.sh && rm install_gcc.sh

#  Install protobuf for ONNX
COPY ./scripts/install_protobuf.sh install_protobuf.sh
RUN bash ./install_protobuf.sh
RUN rm install_protobuf.sh
ENV INSTALLED_PROTOBUF=yes

# Install database packages like LMDB and LevelDB
COPY ./scripts/install_db.sh install_db.sh
RUN bash ./install_db.sh
RUN rm install_db.sh
ENV INSTALLED_DB=yes

# Install vision packages like OpenCV
COPY ./scripts/install_vision.sh install_vision.sh
COPY ./scripts/cache_vision_models.sh cache_vision_models.sh
COPY ./scripts/common_utils.sh common_utils.sh
RUN bash ./install_vision.sh
RUN rm install_vision.sh cache_vision_models.sh common_utils.sh
ENV INSTALLED_VISION=yes

# Install rocm
ENV ROCM_VERSION=6.2.2
COPY ./scripts/install_rocm.sh install_rocm.sh
RUN bash ./install_rocm.sh
RUN rm install_rocm.sh
ENV LD_LIBRARY_PATH "/opt/rocm/lib:/usr/lib"
ENV ROCM_PATH /opt/rocm
ENV PATH /opt/rocm/bin:$PATH
ENV PATH /opt/rocm/hcc/bin:$PATH
ENV PATH /opt/rocm/hip/bin:$PATH
ENV PATH /opt/rocm/opencl/bin:$PATH
ENV PATH /opt/rocm/llvm/bin:$PATH

#Clean rocm instalation (delete packages that will be built from source for the given arch)
COPY ./scripts/install_rocm_clean.sh install_rocm_clean.sh
RUN bash ./install_rocm_clean.sh
RUN rm install_rocm_clean.sh

# Build and install roc* libs:
# rocBLAS
COPY ./scripts/install_rocblas.sh install_rocblas.sh
RUN bash ./install_rocblas.sh
RUN rm install_rocblas.sh

#rocSPARSE
COPY ./scripts/install_rocsparse.sh install_rocsparse.sh
RUN bash ./install_rocsparse.sh
RUN rm install_rocsparse.sh

# rocsSOLVER
COPY ./scripts/install_rocsolver.sh install_rocsolver.sh
RUN bash ./install_rocsolver.sh
RUN rm install_rocsolver.sh

# Build and install hip* libs:
# hipblas-common
COPY ./scripts/install_hipblas-common.sh install_hipblas-common.sh
RUN bash ./install_hipblas-common.sh
RUN rm install_hipblas-common.sh

# hipblas
COPY ./scripts/install_hipblas.sh install_hipblas.sh
RUN bash ./install_hipblas.sh
RUN rm install_hipblas.sh

# hipblaslt
COPY ./scripts/install_hipblaslt.sh install_hipblaslt.sh
RUN bash ./install_hipblaslt.sh
RUN rm install_hipblaslt.sh

# hipsparse
COPY ./scripts/install_hipsparse.sh install_hipsparse.sh
RUN bash ./install_hipsparse.sh
RUN rm install_hipsparse.sh

# hipsolver
COPY ./scripts/install_hipsolver.sh install_hipsolver.sh
RUN bash ./install_hipsolver.sh
RUN rm install_hipsolver.sh

# Build and install MAGMA
COPY ./scripts/install_rocm_magma.sh install_rocm_magma.sh
RUN bash ./install_rocm_magma.sh
RUN rm install_rocm_magma.sh
ENV MAGMA_HOME /opt/rocm/magma
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Install amdsmi
COPY ./scripts/install_amdsmi.sh install_amdsmi.sh
RUN bash ./install_amdsmi.sh
RUN rm install_amdsmi.sh

# Install MIOpen (with composable kernel)
COPY ./scripts/install_rocm_composable_kernel.sh install_rocm_composable_kernel.sh
RUN bash ./install_rocm_composable_kernel.sh
RUN rm install_rocm_composable_kernel.sh
COPY ./scripts/install_rocm_miopen.sh install_rocm_miopen.sh
RUN bash ./install_rocm_miopen.sh
RUN rm install_rocm_miopen.sh

# Install RCCL libs
COPY ./scripts/install_rccl.sh install_rccl.sh
RUN bash ./install_rccl.sh
RUN rm install_rccl.sh
ENV LD_LIBRARY_PATH "/opt/rocm/lib:/opt/rocm/rccl/lib:/usr/lib"

# Install non-default Ninja version
ENV NINJA_VERSION=1.9.0
COPY ./scripts/install_ninja.sh install_ninja.sh
RUN bash ./install_ninja.sh
RUN rm install_ninja.sh

# Install Triton
ENV TRITON_CHECKOUT_POINT="cf34004b8a67d290a962da166f5aa2fc66751326"
COPY ./scripts/install_triton.sh install_triton.sh
COPY ./scripts/common_utils.sh common_utils.sh
COPY ./scripts/triton_version.txt triton_version.txt
RUN bash ./install_triton.sh
RUN rm install_triton.sh common_utils.sh
ENV INSTALLED_TRITON=yes

# Install AOTriton
COPY ./scripts/aotriton_version.txt aotriton_version.txt
COPY ./scripts/common_utils.sh common_utils.sh
COPY ./scripts/install_aotriton.sh install_aotriton.sh
RUN ["/bin/bash", "-c", "./install_aotriton.sh /opt/rocm && rm -rf install_aotriton.sh aotriton_version.txt common_utils.sh"]
ENV AOTRITON_INSTALLED_PREFIX /opt/rocm/aotriton

# Install UCX
ENV UCX_CHECKOUT_POINT="68a742fdbf31a87a9e0bfb3ba0b18e58d8323bf7"
COPY ./scripts/install_ucx.sh install_ucx.sh
RUN bash ./install_ucx.sh
RUN rm install_ucx.sh

# Install UCC
ENV UCC_CHECKOUT_POINT="658aa7fbcf40f0b5072d01a3c872bcf10e44ab54"
COPY ./scripts/install_ucc.sh install_ucc.sh
RUN bash ./install_ucc.sh
RUN rm install_ucc.sh

ENV PATH="/usr/bin:$PATH"
ENV LD_LIBRARY_PATH="/opt/rocm/lib:/opt/rocm/rccl/lib:/usr/lib:/usr/lib/ucc:/usr/lib:/usr/lib/ucx"

# Install OMPI libs
ENV OMPI_HOME /usr
COPY ./scripts/install_ompi.sh install_ompi.sh
RUN bash ./install_ompi.sh
RUN rm install_ompi.sh

ENV LD_LIBRARY_PATH="/opt/rocm/lib:/opt/rocm/rccl/lib:/usr/lib:/usr/lib/openmpi:/usr/lib/ucc:/usr/lib/ucx"

# Configure PyTorch instalation environment
ENV USE_MPI=1
ENV BUILD_TEST=0
ENV BUILD_TEST_LIBTORCH=0
ENV USE_UCC=ON
ENV USE_SYSTEM_UCC=ON
ENV USE_DISTRIBUTED=ON
ENV USE_C10D_UCC=ON
ENV USE_C10D_MPI=ON
ENV TORCH_BLAS_PREFER_HIPBLASLT=0
ENV USE_ROCM=ON
ENV USE_CUDA=OFF
ENV USE_MKLDNN=OFF

CMD ["bash"]