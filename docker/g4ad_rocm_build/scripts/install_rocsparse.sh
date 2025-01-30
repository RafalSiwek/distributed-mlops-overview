#!/bin/bash

set -ex
git clone --recursive https://github.com/ROCmSoftwarePlatform/rocSPARSE.git -b rocm-${ROCM_VERSION}
pushd rocSPARSE
git submodule update --init --recursive

./install.sh -i --rocblas-path /opt/rocm \
      -a $PYTORCH_ROCM_ARCH
popd
rm -rf rocSPARSE