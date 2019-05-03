# rapids-dataproc

Setup:
[Install Google Cloud SDK](https://cloud.google.com/sdk/install)

The SDK setup process will create new SSH keys: ~/.ssh/google_compute_engine

Overview:
1. Dataproc creates a cluster with a master and workers
2. On startup, "initialization action" scripts are run on all nodes
3. Our init actions:
    a. install nvidia driver
    b. install conda
    c. install RAPIDS packages
    d. install Jupyter
    e. start dask-scheduler and workers

#Artifacts#:

Binaries and initialization scripts are copied into Google Cloud Storage (gcs) bucket: rapids-test-1.

Examples:
gs://rapidsai-test-1/init-actions/install-gpu-driver.sh
gs://rapidsai-test-1/binaries/NVIDIA-Linux-x86_64-410.104.run

Add or Update Artifacts in GCS:
```
gsutil cp xgboost-0.83.dev0-py3-none-any.whl gs://rapidsai-test-1/binaries/xgboost-0.83.dev0-py3-none-any.whl
```

Create a Cluster ([script avail](scripts/create-cluster.sh)):
```
gcloud beta dataproc clusters create randy \
--zone us-east1-c \
--master-accelerator type=nvidia-tesla-t4 \
--worker-accelerator type=nvidia-tesla-t4,count=1 \
--metadata "JUPYTER_PORT=8888" \
--initialization-actions gs://rapidsai-test-1/init-actions/install-gpu-driver.sh,gs://rapidsai-test-1/init-actions/conda-env-setup.sh,gs://dataproc-initialization-actions/jupyter/jupyter.sh,gs://rapidsai-test-1/init-actions/dask-network-setup.sh
```

SSH into the master ([script avail](scripts/ssh.sh)):
```
gcloud compute --project "nv-ai-infra" ssh --zone "us-east1-c" randy-m
```

SSH into one of the workers:
```
gcloud compute --project "nv-ai-infra" ssh --zone "us-east1-c" randy-worker-0
```

Setup SSH tunnel for local access to Jupyter:
```
# get the IP of the master from GCloud Console
ssh -i ~/.ssh/google_compute_engine -L 8888:localhost:8888 -L 8787:localhost:8787 dev@35.231.99.40
```

[Add SSDs](https://cloud.google.com/compute/docs/disks/add-persistent-disk#use_multi_instances) with taxi data pre-loaded, once for each worker:
```
gcloud compute instances attach-disk randy-w-0 --disk pd-ssd-rapids-1 --mode ro

```

Mount the disk:
```
gcloud compute --project "nv-ai-infra" ssh --zone "us-east1-c" randy-worker-0
sudo mkdir -p /mnt/disks/rapids
sudo mount -o discard,defaults /dev/sdb /mnt/disks/rapids
```

Delete the cluster:
```
gcloud dataproc clusters delete randy
```
