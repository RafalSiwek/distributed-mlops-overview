#!/bin/bash

set -ex

apt-get update

# Cleanup
apt-get autoclean && apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
