#!/bin/bash

set -ex
git clone --recursive https://github.com/ROCmSoftwarePlatform/rocSOLVER.git -b rocm-${ROCM_VERSION}
pushd rocSOLVER
git submodule update --init --recursive

./install.sh -i \
      -a $PYTORCH_ROCM_ARCH \
      --rocblas-path /opt/rocm \
      --rocsparse-path /opt/rocm
popd
rm -rf rocSOLVER