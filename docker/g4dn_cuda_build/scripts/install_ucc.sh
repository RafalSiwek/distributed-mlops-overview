#!/bin/bash

set -ex

git clone --recursive https://github.com/openucx/ucc.git
pushd ucc
git checkout ${UCC_CHECKOUT_POINT}
git submodule update --init --recursive

./autogen.sh
NVCC_GENCODE="-gencode=arch=compute_75,code=sm_75"
./configure --prefix=/usr                 \
  --with-ucx=/usr                         \
  --with-cuda=/usr/local/cuda             \
  --with-nvcc-gencode="${NVCC_GENCODE}"   \
  --with-tls=ucp
time make -j
sudo make install

popd
rm -rf ucc