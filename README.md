# rapids-dataproc

Pre-Requisites:
1. [Install Google Cloud SDK](https://cloud.google.com/sdk/install)
2. [Initialize the Google Cloud SDK](https://cloud.google.com/sdk/docs/initializing)

The SDK setup process will create new SSH keys in ~/.ssh/google_compute_engine

Overview:
1. Dataproc creates a cluster with a master and workers
2. On startup, "initialization action" scripts are run on all nodes
3. Our init actions do the following:
    - [install nvidia driver](init-actions/install-gpu-driver.sh)
    - [install miniconda](https://github.com/GoogleCloudPlatform/dataproc-initialization-actions/tree/master/conda)
    - [install RAPIDS conda packages](init-actions/conda-env-setup.sh)
    - install [Jupyter notebook](https://jupyter.org/)
    - [start dask-scheduler and workers](init-actions/dask-network-setup.sh)

# Cluster Setup:

Create a Dataproc cluster ([script available](scripts/create-cluster.sh)) using the gcloud CLI:
```
DATAPROC_BUCKET=rapidsai-test-1

gcloud beta dataproc clusters create test \
--zone us-east1-c \
--master-accelerator type=nvidia-tesla-t4 \
--worker-accelerator type=nvidia-tesla-t4,count=2 \
--num-workers 2 \
--worker-machine-type n1-standard-32 \
--metadata "JUPYTER_PORT=8888,gpu-driver=NVIDIA-Linux-x86_64-410.104.run" \
--bucket $DATAPROC_BUCKET \
--initialization-actions gs://rapidsai-test-1/init-actions/install-gpu-driver.sh,gs://$DATAPROC_BUCKET/init-actions/conda-env-setup.sh,gs://dataproc-initialization-actions/jupyter/jupyter.sh,gs://$DATAPROC_BUCKET/init-actions/dask-network-setup.sh
```

Installing the recent GPU driver and conda environment takes around 15 minutes. Afterwards, Jupyter will be available from the master node.

An [example notebook](notebooks/NYCTaxi-E2E.ipynb) is provided demonstrating end to end data pre-processing (ETL) and model training with RAPIDS APIs.

# Cluster Teardown:

Delete the cluster:
```
gcloud dataproc clusters delete test
```

# Useful Commands

SSH into the master ([script avail](scripts/ssh.sh)):
```
gcloud compute --project ${YOUR_PROJECT} ssh --zone "us-east1-c" test-m
```

SSH into the first worker:
```
gcloud compute --project ${YOUR_PROJECT} ssh --zone "us-east1-c" test-w-0
```

Setup SSH tunnel for local access to Jupyter:
```
# get the external IP of the master from GCloud Console, or use "curl ifconfig.me"
ssh -i ~/.ssh/google_compute_engine -L 8888:localhost:8888 -L 8787:localhost:8787 dev@${EXTERNAL_IP}
```
