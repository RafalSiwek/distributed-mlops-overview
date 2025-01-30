#!/bin/bash

set -ex

source "$(dirname "${BASH_SOURCE[0]}")/common_utils.sh"

get_conda_version() {
  conda list -n py_$ANACONDA_PYTHON_VERSION | grep -w $* | head -n 1 | awk '{print $2}'
}

conda_reinstall() {
  conda install -q -n py_$ANACONDA_PYTHON_VERSION -y --force-reinstall $*
}

apt update
apt-get install -y gpg-agent

CMAKE_VERSION=$(get_conda_version cmake)
NUMPY_VERSION=$(get_conda_version numpy)

export MAX_JOBS=$(nproc)

# Git checkout triton
mkdir /var/lib/triton
pushd /var/lib/

git clone --recursive https://github.com/triton-lang/triton triton
cd triton
git checkout ${TRITON_CHECKOUT_POINT}
git submodule update --init --recursive
cd python

# TODO: remove patch setup.py once we have a proper fix for https://github.com/triton-lang/triton/issues/4527
sed -i -e 's/https:\/\/tritonlang.blob.core.windows.net\/llvm-builds/https:\/\/oaitriton.blob.core.windows.net\/public\/llvm-builds/g' setup.py

pip_install -e .

# TODO: This is to make sure that the same cmake and numpy version from install conda
# script is used. Without this step, the newer cmake version (3.25.2) downloaded by
# triton build step via pip will fail to detect conda MKL. Once that issue is fixed,
# this can be removed.
#
# The correct numpy version also needs to be set here because conda claims that it
# causes inconsistent environment.  Without this, conda will attempt to install the
# latest numpy version, which fails ASAN tests with the following import error: Numba
# needs NumPy 1.20 or less.
conda_reinstall cmake="${CMAKE_VERSION}"
# Note that we install numpy with pip as conda might not have the version we want
pip_install --force-reinstall numpy=="${NUMPY_VERSION}"