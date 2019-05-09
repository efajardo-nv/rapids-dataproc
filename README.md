# rapids-dataproc

Pre-Req:
1. [Install Google Cloud SDK](https://cloud.google.com/sdk/install)
2. [Initialize the Google Cloud SDK](https://cloud.google.com/sdk/docs/initializing)

The SDK setup process will create new SSH keys: ~/.ssh/google_compute_engine

Overview:
1. Dataproc creates a cluster with a master and workers
2. On startup, "initialization action" scripts are run on all nodes
3. Our init actions automatically do the following:
    - [install nvidia driver](init-actions/install-gpu-driver.sh)
    - [install miniconda](https://github.com/GoogleCloudPlatform/dataproc-initialization-actions/tree/master/conda)
    - [install RAPIDS conda packages](init-actions/conda-env-setup.sh)
    - install [Jupyter notebook](https://jupyter.org/)
    - [start dask-scheduler and workers](init-actions/dask-network-setup.sh)

# Cluster Setup:

Create a Cluster ([script available](scripts/create-cluster.sh)):
```
gcloud beta dataproc clusters create test \
--zone us-east1-c \
--master-accelerator type=nvidia-tesla-t4 \
--worker-accelerator type=nvidia-tesla-t4,count=1 \
--num-workers 1 \
--metadata "JUPYTER_PORT=8888" \
--bucket rapidsai-test-1 \
--initialization-actions gs://rapidsai-test-1/init-actions/install-gpu-driver.sh,gs://rapidsai-test-1/init-actions/conda-env-setup.sh,gs://dataproc-initialization-actions/jupyter/jupyter.sh,gs://rapidsai-test-1/init-actions/dask-network-setup.sh
```

# Cluster Teardown:

Stop/delete the cluster:
```
gcloud dataproc clusters delete test
```

# Useful Info

SSH into the master ([script avail](scripts/ssh.sh)):
```
gcloud compute --project "nv-ai-infra" ssh --zone "us-east1-c" test-m
```

SSH into one of the workers:
```
gcloud compute --project "nv-ai-infra" ssh --zone "us-east1-c" test-w-0
```

Setup SSH tunnel for local access to Jupyter:
```
# get the IP of the master from GCloud Console
ssh -i ~/.ssh/google_compute_engine -L 8888:localhost:8888 -L 8787:localhost:8787 dev@35.231.99.40
```

Taxi data _is_ available in a public GCP storage bucket: gcs://anaconda-public-data/nyc-taxi/csv, but it's not fast.

To make testing faster, we prepared [an SSD](https://cloud.google.com/compute/docs/disks/add-persistent-disk#use_multi_instances) with taxi data pre-loaded.

You'll need to attach it to your cluster nodes:
```
# example with 1 master, 2 workers
gcloud compute instances attach-disk test-m --zone "us-east1-c" --disk pd-ssd-rapids-2 --mode ro
gcloud compute instances attach-disk test-w-0 --zone "us-east1-c" --disk pd-ssd-rapids-2 --mode ro
gcloud compute instances attach-disk test-w-1 --zone "us-east1-c" --disk pd-ssd-rapids-2 --mode ro
```

Mount the disk on each node:
```
gcloud compute --project "nv-ai-infra" ssh --zone "us-east1-c" test-m

sudo mkdir -p /data
sudo mount -o discard,defaults /dev/sdb /data

gcloud compute --project "nv-ai-infra" ssh --zone "us-east1-c" test-w-0

sudo mkdir -p /data
sudo mount -o discard,defaults /dev/sdb /data

gcloud compute --project "nv-ai-infra" ssh --zone "us-east1-c" test-w-1

sudo mkdir -p /data
sudo mount -o discard,defaults /dev/sdb /data
```

# Artifacts:

Binaries and initialization scripts are copied into Google Cloud Storage (gcs) bucket: rapids-test-1.

Examples:
gs://rapidsai-test-1/init-actions/install-gpu-driver.sh
gs://rapidsai-test-1/binaries/NVIDIA-Linux-x86_64-410.104.run

Add or Update Artifacts in GCS:
```
gsutil cp xgboost-0.83.dev0-py3-none-any.whl gs://rapidsai-test-1/binaries/xgboost-0.83.dev0-py3-none-any.whl
```
