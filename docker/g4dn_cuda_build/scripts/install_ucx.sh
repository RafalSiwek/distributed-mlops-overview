#!/bin/bash

set -ex

git clone --recursive https://github.com/openucx/ucx.git
pushd ucx
git checkout ${UCX_CHECKOUT_POINT}
git submodule update --init --recursive

./autogen.sh
./configure --prefix=/usr           \
    --with-cuda=/usr/local/cuda     \
    --enable-profiling              \
    --enable-stats
time make -j
sudo make install

popd
rm -rf ucx