#!/bin/bash

set -ex

BASE_URL="https://repo.anaconda.com/miniconda"
CONDA_FILE="Miniconda3-latest-Linux-x86_64.sh"

MAJOR_PYTHON_VERSION=$(echo "$ANACONDA_PYTHON_VERSION" | cut -d . -f 1)
MINOR_PYTHON_VERSION=$(echo "$ANACONDA_PYTHON_VERSION" | cut -d . -f 2)

case "$MAJOR_PYTHON_VERSION" in
3);;
*)
    echo "Unsupported ANACONDA_PYTHON_VERSION: $ANACONDA_PYTHON_VERSION"
    exit 1
    ;;
esac

mkdir -p /opt/conda

source "$(dirname "${BASH_SOURCE[0]}")/common_utils.sh"

pushd /tmp
wget -q "${BASE_URL}/${CONDA_FILE}"
# NB: Manually invoke bash per https://github.com/conda/conda/issues/10431
bash "${CONDA_FILE}" -b -f -p "/opt/conda"
popd

# NB: Don't do this, rely on the rpath to get it right
#echo "/opt/conda/lib" > /etc/ld.so.conf.d/conda-python.conf
#ldconfig
sed -e 's|PATH="\(.*\)"|PATH="/opt/conda/bin:\1"|g' -i /etc/environment
export PATH="/opt/conda/bin:$PATH"

# Ensure we run conda in a directory that jenkins has write access to
pushd /opt/conda

# Prevent conda from updating to 4.14.0, which causes docker build failures
# See https://hud.pytorch.org/pytorch/pytorch/commit/754d7f05b6841e555cea5a4b2c505dd9e0baec1d
# Uncomment the below when resolved to track the latest conda update
# conda update -y -n base conda

export SYSROOT_DEP="sysroot_linux-64=2.17"

# Install correct Python version
# Also ensure sysroot is using a modern GLIBC to match system compilers
conda create -n py_$ANACONDA_PYTHON_VERSION -y\
            python="$ANACONDA_PYTHON_VERSION" \
            ${SYSROOT_DEP}

# libstdcxx from conda default channels are too old, we need GLIBCXX_3.4.30
# which is provided in libstdcxx 12 and up.
conda_install libstdcxx-ng=12.3.0 -c conda-forge

# Install PyTorch conda deps, as per https://github.com/pytorch/pytorch README

CONDA_COMMON_DEPS="astunparse pyyaml mkl=2021.4.0 mkl-include=2021.4.0 setuptools"
NUMPY_VERSION=1.26.0

conda_install ${CONDA_COMMON_DEPS}

# Install llvm-8 as it is required to compile llvmlite-0.30.0 from source
# and libpython-static for torch deploy
conda_install llvmdev=8.0.0 "libpython-static=${ANACONDA_PYTHON_VERSION}"

# Use conda cmake in some cases. Conda cmake will be newer than our supported
# min version (3.5 for xenial and 3.10 for bionic), so we only do it in those
# following builds that we know should use conda. Specifically, Ubuntu bionic
# and focal cannot find conda mkl with stock cmake, so we need a cmake from conda
conda_install cmake

# Install some other packages, including those needed for Python test reporting
pip_install -r /opt/conda/requirements.txt
pip_install numpy=="$NUMPY_VERSION"
pip_install -U scikit-learn

popd
