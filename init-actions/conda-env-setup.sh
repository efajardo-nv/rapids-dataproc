#!/usr/bin/env bash

apt install libopenblas-base libomp-dev

CONDA_ENV_YAML_GSC_LOC="gs://rapidsai-test-1/init-actions/conda-environment.yml"
CONDA_ENV_YAML_PATH="/root/conda-environment.yml"
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
git clone https://github.com/rapidsai/dask-cudf
cd dask-cudf
pip install .
