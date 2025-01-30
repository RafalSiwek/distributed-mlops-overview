#!/bin/bash

set -ex

apt-get update
apt-get install -y --no-install-recommends gpg-agent
apt-get install -y kmod
apt-get install -y wget

# Need the libc++1 and libc++abi1 libraries to allow torch._C to load at runtime
apt-get install -y libc++1
apt-get install -y libc++abi1

# Add amdgpu repository
UBUNTU_VERSION_NAME=`cat /etc/os-release | grep UBUNTU_CODENAME | awk -F= '{print $2}'`
echo "deb [arch=amd64] https://repo.radeon.com/amdgpu/${ROCM_VERSION}/ubuntu ${UBUNTU_VERSION_NAME} main" > /etc/apt/sources.list.d/amdgpu.list

# Add rocm repository
wget -qO - http://repo.radeon.com/rocm/rocm.gpg.key | apt-key add -
rocm_baseurl="http://repo.radeon.com/rocm/apt/${ROCM_VERSION}"
echo "deb [arch=amd64] ${rocm_baseurl} ${UBUNTU_VERSION_NAME} main" > /etc/apt/sources.list.d/rocm.list
echo -e 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' | tee /etc/apt/preferences.d/rocm-pin-600
apt-get update --allow-insecure-repositories

DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated \
                rocm rocm-llvm-dev


