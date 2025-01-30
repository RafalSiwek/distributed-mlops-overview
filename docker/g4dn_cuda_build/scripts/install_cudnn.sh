
#!/bin/bash

set -ex

# cuDNN license: https://developer.nvidia.com/cudnn/license_agreement
mkdir tmp_cudnn
pushd tmp_cudnn
CUDNN_NAME="cudnn-linux-x86_64-9.1.0.70_cuda12-archive"

curl --retry 3 -OLs https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-x86_64/${CUDNN_NAME}.tar.xz
tar xf ${CUDNN_NAME}.tar.xz
cp -a ${CUDNN_NAME}/include/* /usr/local/cuda/include/
cp -a ${CUDNN_NAME}/lib/* /usr/local/cuda/lib64/
popd
rm -rf tmp_cudnn
ldconfig
