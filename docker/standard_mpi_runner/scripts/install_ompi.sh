#!/bin/bash

set -ex

git clone --recursive https://github.com/open-mpi/ompi.git -b v5.0.x
pushd ompi
git submodule update --init --recursive

./autogen.pl
./configure --prefix=/usr          \
  --with-ucx=/usr                  \
  --with-ucx=/usr                      
time make -j$(nproc)
sudo make install

popd
rm -rf ompi

# Install and configure ssh-related libs
apt-get install -y ssh openssh-server

mkdir /var/run/sshd
mkdir /root/.ssh
touch /root/.ssh/authorized_keys
chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#\(StrictModes \).*/\1no/g' /etc/ssh/sshd_config
echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config
