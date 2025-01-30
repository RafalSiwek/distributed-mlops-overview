#!/bin/bash

set -ex
git clone --recursive https://github.com/ROCm/hipBLAS-common.git -b mainline
pushd hipBLAS-common
git submodule update --init --recursive

python ./rmake.py --install
pushd build
dpkg -i *.deb
popd
popd
rm -rf hipBLAS-common
