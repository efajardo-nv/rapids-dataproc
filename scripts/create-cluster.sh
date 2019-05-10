NAME=$1
WORKERS=$2
GPUS_PER_WORKER=$3
DATAPROC_BUCKET=rapidsai-test-1

gcloud beta dataproc clusters create $NAME \
--zone us-east1-c \
--master-accelerator type=nvidia-tesla-t4 \
--worker-accelerator type=nvidia-tesla-t4,count=$GPUS_PER_WORKER \
--num-workers $WORKERS \
--worker-machine-type n1-standard-32 \
--metadata "JUPYTER_PORT=8888,gpu-driver=NVIDIA-Linux-x86_64-410.104.run" \
--bucket $DATAPROC_BUCKET \
--initialization-actions gs://$DATAPROC_BUCKET/init-actions/install-gpu-driver.sh,gs://$DATAPROC_BUCKET/init-actions/conda-env-setup.sh,gs://dataproc-initialization-actions/jupyter/jupyter.sh,gs://$DATAPROC_BUCKET/init-actions/dask-network-setup.sh
