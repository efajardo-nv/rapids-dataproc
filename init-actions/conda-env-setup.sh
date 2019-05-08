#!/usr/bin/env bash

apt install libopenblas-base libomp-dev

readonly DATAPROC_BUCKET="$(/usr/share/google/get_metadata_value attributes/dataproc-bucket)"
readonly CONDA_ENV_YAML_GSC_LOC="gs://${DATAPROC_BUCKET}/init-actions/conda-environment.yml"
readonly CONDA_ENV_YAML_PATH="/root/conda-environment.yml"

echo "Downloading conda environment at $CONDA_ENV_YAML_GSC_LOC to $CONDA_ENV_YAML_PATH ... "
gsutil -m cp -r $CONDA_ENV_YAML_GSC_LOC $CONDA_ENV_YAML_PATH
gsutil -m cp -r gs://dataproc-initialization-actions/conda/bootstrap-conda.sh .
gsutil -m cp -r gs://dataproc-initialization-actions/conda/install-conda-env.sh .

chmod 755 ./*conda*.sh

# Install Miniconda / conda
./bootstrap-conda.sh
# Create / Update conda environment via conda yaml
CONDA_ENV_YAML=$CONDA_ENV_YAML_PATH ./install-conda-env.sh

source /etc/profile.d/conda.sh

# install xgboost from wheel
# ToDo: install from conda package instead
#XGBOOST_WHEEL=xgboost-0.83.dev0-py3-none-any.whl
#gsutil cp gs://${DATAPROC_BUCKET}/binaries/${XGBOOST_WHEEL} ${XGBOOST_WHEEL}
#pip install ${XGBOOST_WHEEL}

# ToDo: install from conda package instead
#gsutil cp gs://${DATAPROC_BUCKET}/binaries/libnccl* .
#apt install -y ./libnccl2_2.4.6-1+cuda10.0_amd64.deb
#apt install -y ./libnccl-dev_2.4.6-1+cuda10.0_amd64.deb
