#!/bin/bash

apt-get update
apt-get install -y pciutils
export DEBIAN_FRONTEND=noninteractive
apt-get install -y "linux-headers-$(uname -r)"
gsutil cp gs://rapidsai-test-1/binaries/NVIDIA-Linux-x86_64-410.104.run .
chmod a+x ./NVIDIA-Linux-x86_64-410.104.run
./NVIDIA-Linux-x86_64-410.104.run --silent
