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

# workaround for https://github.com/rapidsai/dask-cudf/issues/214
# ToDo: install from conda package instead
pip install git+https://github.com/rapidsai/dask-cudf.git@branch-0.7

# install xgboost from wheel
# ToDo: install from conda package instead
XGBOOST_WHEEL=xgboost-0.83.dev0-py3-none-any.whl
gsutil cp gs://rapidsai-test-1/binaries/${XGBOOST_WHEEL} ${XGBOOST_WHEEL}
pip install ${XGBOOST_WHEEL}

# ToDo: install from conda package instead
pip install git+https://github.com/rapidsai/dask-xgboost.git@dask-cudf
