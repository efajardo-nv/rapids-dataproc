#!/bin/bash

apt-get update
apt-get install -y pciutils
export DEBIAN_FRONTEND=noninteractive
apt-get install -y "linux-headers-$(uname -r)"

readonly DATAPROC_BUCKET="$(/usr/share/google/get_metadata_value attributes/dataproc-bucket)"
readonly GPU_DRIVER=$(/usr/share/google/get_metadata_value attributes/gpu-driver)

readonly GPU_DRIVER_URL="http://us.download.nvidia.com/tesla/410.104/NVIDIA-Linux-x86_64-410.104.run"
wget ${GPU_DRIVER_URL}
chmod a+x "./${GPU_DRIVER}"
"./${GPU_DRIVER}" --silent
