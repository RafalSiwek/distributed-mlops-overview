#!/bin/bash

set -ex
git clone --recursive https://github.com/ROCmSoftwarePlatform/hipSOLVER.git -b rocm-${ROCM_VERSION}
pushd hipSOLVER
git submodule update --init --recursive

./install.sh -id                \
    --rocblas-path /opt/rocm    \
    --hipblas-path /opt/rocm    \
    --rocsolver-path /opt/rocm  \
    --rocsparse-path /opt/rocm  \
    --hipsparse-path /opt/rocm
popd
rm -rf hipSOLVER