#!/bin/bash

set -ex

git clone --recursive https://github.com/ROCm/rocBLAS.git -b rocm-${ROCM_VERSION}
pushd rocBLAS
git submodule update --init --recursive

./install.sh -id \
        -a $PYTORCH_ROCM_ARCH
popd
rm -rf rocBLAS