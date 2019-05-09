NAME=$1
WORKERS=$2
GPUS_PER_WORKER=$3

gcloud beta dataproc clusters create $NAME \
--zone us-east1-c \
--master-accelerator type=nvidia-tesla-t4 \
--worker-accelerator type=nvidia-tesla-t4,count=$GPUS_PER_WORKER \
--num-workers $WORKERS \
--metadata "JUPYTER_PORT=8888,gpu-driver=NVIDIA-Linux-x86_64-410.104.run" \
--bucket "rapidsai-test-1" \
--initialization-actions gs://rapidsai-test-1/init-actions/install-gpu-driver.sh,gs://rapidsai-test-1/init-actions/conda-env-setup.sh,gs://dataproc-initialization-actions/jupyter/jupyter.sh,gs://rapidsai-test-1/init-actions/dask-network-setup.sh
