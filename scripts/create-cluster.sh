NAME=$1

DATAPROC_BUCKET=rapidsai-test-1

gcloud beta dataproc clusters create $NAME \
--zone us-east1-c \
--master-accelerator type=nvidia-tesla-t4,count=4 \
--master-machine-type n1-standard-32 \
--worker-accelerator type=nvidia-tesla-t4,count=4 \
--worker-machine-type n1-standard-32 \
--metadata "JUPYTER_PORT=8888" \
--initialization-actions gs://$DATAPROC_BUCKET/rapids/install-gpu-driver.sh,gs://$DATAPROC_BUCKET/rapids/install-rapids.sh,gs://$DATAPROC_BUCKET/rapids/launch-dask.sh,gs://dataproc-initialization-actions/jupyter/jupyter.sh
