#!/bin/bash

set -ex

apt remove -f -y hipblas hipblaslt rccl rocblas rocsparse rocsolver hipsolver hipsparse
