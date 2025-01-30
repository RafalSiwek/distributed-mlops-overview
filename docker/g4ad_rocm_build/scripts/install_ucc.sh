#!/bin/bash

set -ex

git clone --recursive https://github.com/openucx/ucc.git
pushd ucc
git checkout ${UCC_CHECKOUT_POINT}
git submodule update --init --recursive

./autogen.sh
./configure --prefix=/usr                               \
  --with-ucx=/usr                                       \
  --with-rocm=/opt/rocm                                 \
  --with-rocm-arch="--offload-arch=$PYTORCH_ROCM_ARCH"  \
  --with-tls=ucp
time make -j
sudo make install

popd
rm -rf ucc