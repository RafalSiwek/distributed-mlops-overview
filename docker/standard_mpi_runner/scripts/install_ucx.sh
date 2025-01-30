#!/bin/bash

set -ex

git clone --recursive https://github.com/openucx/ucx.git
pushd ucx
git checkout ${UCX_CHECKOUT_POINT}
git submodule update --init --recursive

./autogen.sh
./configure --prefix=/usr           \
    --with-rocm=/opt/rocm           \
    --enable-profiling              \
    --enable-stats
time make -j$(nproc)
sudo make install

popd
rm -rf ucx