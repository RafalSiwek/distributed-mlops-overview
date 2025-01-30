#!/bin/bash

set -ex
git clone --recursive https://github.com/ROCmSoftwarePlatform/hipSPARSE.git -b rocm-${ROCM_VERSION}
pushd hipSPARSE
git submodule update --init --recursive

./install.sh -i
popd
rm -rf hipSPARSE