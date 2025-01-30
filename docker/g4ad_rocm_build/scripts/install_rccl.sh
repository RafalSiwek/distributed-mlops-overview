#!/bin/bash

set -ex

git clone --recursive https://github.com/ROCm/rccl.git -b rocm-${ROCM_VERSION}
pushd rccl
git submodule update --init --recursive

./install.sh -if --amdgpu_targets gfx1011
popd
rm -rf rccl
