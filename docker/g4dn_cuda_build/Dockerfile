FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

USER root

ENV DEBIAN_FRONTEND="noninteractive"

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

# install openssl
COPY ./scripts/install_openssl.sh install_openssl.sh
ENV OPENSSL_ROOT_DIR="/opt/openssl"
RUN bash ./install_openssl.sh
ENV OPENSSL_DIR="/opt/openssl"

# Install Triton
ENV TRITON_CHECKOUT_POINT="cf34004b8a67d290a962da166f5aa2fc66751326"
COPY ./scripts/install_triton.sh install_triton.sh
COPY ./scripts/common_utils.sh common_utils.sh
COPY ./scripts/triton_version.txt triton_version.txt
RUN bash ./install_triton.sh
RUN rm install_triton.sh common_utils.sh
ENV INSTALLED_TRITON=yes

# AWS specific CUDA build guidance
ENV TORCH_CUDA_ARCH_LIST="Turing"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CUDA_PATH="/usr/local/cuda"

# Add jni.h for java host build
COPY ./scripts/install_jni.sh install_jni.sh
COPY ./scripts/java/jni.h jni.h
RUN bash ./install_jni.sh && rm install_jni.sh

# Install LLVM dev version (Defined in the pytorch/builder github repository)
COPY --from=pytorch/llvm:9.0.1 /opt/llvm /opt/llvm

# Install CUDNN
ENV CUDNN_VERSION=9
COPY ./scripts/install_cudnn.sh install_cudnn.sh
RUN bash install_cudnn.sh
RUN rm install_cudnn.sh

# Install CUSPARSELT
COPY ./scripts/install_cusparselt.sh install_cusparselt.sh
RUN bash install_cusparselt.sh
RUN rm install_cusparselt.sh

# Install CUDSS
COPY ./scripts/install_cudss.sh install_cudss.sh
RUN bash install_cudss.sh
RUN rm install_cudss.sh

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
ENV LD_LIBRARY_PATH="/usr/lib:/usr/lib/ucc:/usr/lib:/usr/lib/ucx:${LD_LIBRARY_PATH}"

# Install OMPI libs
ENV OMPI_HOME /usr
COPY ./scripts/install_ompi.sh install_ompi.sh
RUN bash ./install_ompi.sh
RUN rm install_ompi.sh
ENV LD_LIBRARY_PATH="/usr/lib/openmpi:${LD_LIBRARY_PATH}"

# Delete /usr/local/cuda-11.X/cuda-11.X symlinks
RUN if [ -h /usr/local/cuda-11.6/cuda-11.6 ]; then rm /usr/local/cuda-11.6/cuda-11.6; fi
RUN if [ -h /usr/local/cuda-11.7/cuda-11.7 ]; then rm /usr/local/cuda-11.7/cuda-11.7; fi
RUN if [ -h /usr/local/cuda-12.1/cuda-12.1 ]; then rm /usr/local/cuda-12.1/cuda-12.1; fi

# Configure PyTorch instalation environment
ENV TORCH_CUDA_ARCH_LIST="Turing"
ENV USE_MPI=1
ENV BUILD_TEST=0
ENV BUILD_TEST_LIBTORCH=0
ENV USE_UCC=ON
ENV USE_SYSTEM_UCC=ON
ENV USE_DISTRIBUTED=ON
ENV USE_C10D_UCC=ON
ENV USE_C10D_MPI=ON
ENV TORCH_BLAS_PREFER_CUBLASLT=0
ENV USE_ROCM=OFF
ENV USE_CUDA=ON
ENV USE_MKLDNN=OFF


CMD [ "bash" ]