#!/bin/bash

set -ex

git clone --recursive https://github.com/ROCm/hipBLAS.git -b rocm-${ROCM_VERSION}
pushd hipBLAS
git submodule update --init --recursive

./install.sh -i --rocblas-path /opt/rocm --rocsolver-path /opt/rocm
popd
rm -rf hipBLAS
