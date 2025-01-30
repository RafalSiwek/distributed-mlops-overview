#!/bin/bash

set -ex

# Install common dependencies
apt-get update
# TODO: Some of these may not be necessary
deploy_deps="libffi-dev libbz2-dev libreadline-dev libncurses5-dev libncursesw5-dev libgdbm-dev libsqlite3-dev uuid-dev tk-dev"
numpy_deps="gfortran"
apt-get install -y --no-install-recommends \
  $numpy_deps \
  ${deploy_deps} \
  cmake=3.22* \
  apt-transport-https \
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  curl \
  git \
  libatlas-base-dev \
  libc6-dbg \
  libyaml-dev \
  libz-dev \
  libjemalloc2 \
  libjpeg-dev \
  libasound2-dev \
  libsndfile-dev \
  software-properties-common \
  wget \
  sudo \
  vim \
  jq \
  libtool \
  vim \
  unzip \
  gpg-agent \
  gdb \
  flex \
  libpmix-dev


# Should resolve issues related to various apt package repository cert issues
# see: https://github.com/pytorch/pytorch/issues/65931
apt-get install -y libgnutls30


# Cleanup package manager
apt-get autoclean && apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Valgrind separately since the apt-get version is too old.
mkdir valgrind_build && cd valgrind_build
VALGRIND_VERSION=3.20.0
wget https://ossci-linux.s3.amazonaws.com/valgrind-${VALGRIND_VERSION}.tar.bz2
tar -xjf valgrind-${VALGRIND_VERSION}.tar.bz2
cd valgrind-${VALGRIND_VERSION}
./configure --prefix=/usr/local
make -j$[$(nproc) - 2]
sudo make install
cd ../../
rm -rf valgrind_build
alias valgrind="/usr/local/bin/valgrind"
