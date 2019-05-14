# Intro to Dataproc

Google Cloud Dataproc is a tool for launching clusters of VMs in Google Cloud.

To try it out, login to the [Google Cloud Console](https://console.cloud.google.com/), click the Navigation menu on the top left, and scroll down until you see Dataproc under the "Big Data" section. You can use it to create a cluster which you can login to or interact with directly. You can launch a ["job"](https://cloud.google.com/dataproc/docs/guides/submit-job) (a data processing script to run on a newly provisioned cluster), or a ["workflow"](https://cloud.google.com/dataproc/docs/concepts/workflows/using-workflows), which is a series of jobs.

[RAPIDS in Dataproc](https://github.com/randerzander/dataproc-initialization-actions/tree/master/rapids) requires you to use the Google Cloud SDK command line interface. Future versions of Dataproc will support configuring GPUs in Dataproc clusters through its web UI.

Pre-Requisites:
1. [Install Google Cloud SDK](https://cloud.google.com/sdk/install)
2. [Initialize the Google Cloud SDK](https://cloud.google.com/sdk/docs/initializing)

The SDK setup process will create new SSH keys in ~/.ssh/google_compute_engine

Overview of Dataproc:
1. Dataproc creates a cluster with a master and workers
2. On startup, "initialization action" scripts are run on all nodes
3. RAPIDS init actions do the following:
    - [install nvidia driver](https://github.com/randerzander/dataproc-initialization-actions/blob/master/rapids/install-gpu-driver.sh)
    - [install miniconda](https://github.com/GoogleCloudPlatform/dataproc-initialization-actions/tree/master/conda)
    - [install RAPIDS conda packages](https://github.com/randerzander/dataproc-initialization-actions/blob/master/rapids/install-rapids.sh)
    - [start dask-scheduler and workers](https://github.com/randerzander/dataproc-initialization-actions/blob/master/rapids/launch-dask.sh)

# Create a Dataproc cluster:

Note that the shell variable "$DATAPROC_BUCKET" tells your Dataproc cluster where to look for initialization action scripts. Until [the PR](https://github.com/GoogleCloudPlatform/dataproc-initialization-actions/pull/529) merges, you can test by using `$DATAPROC_BUCKET=rapidsai-test-1`, which is an nvidia owned bucket where we have uploaded the init action scripts. Once the PR merges, you can use `$DATAPROC_BUCKET=dataproc-initialization-actions` tthe "official" source of Dataproc init actions.

If you don't have access to the "nv-ai-infra" project, you'll have to [publish the RAPIDS init actions to your own bucket](scripts/publish.sh).

Using the gcloud CLI (script provided)[scripts/create-cluster.sh]:
```
DATAPROC_BUCKET=rapidsai-test-1

gcloud beta dataproc clusters create <YOUR_CLUSTER_NAME> \
--zone us-east1-c \
--master-accelerator type=nvidia-tesla-t4,count=4 \
--master-machine-type n1-standard-32 \
--worker-accelerator type=nvidia-tesla-t4,count=4 \
--worker-machine-type n1-standard-32 \
--metadata "JUPYTER_PORT=8888" \
--bucket <YOUR_BUCKET> \
--initialization-actions gs://$DATAPROC_BUCKET/rapids/install-gpu-driver.sh,gs://$DATAPROC_BUCKET/rapids/install-rapids.sh,gs://$DATAPROC_BUCKET/rapids/launch-dask.sh,gs://dataproc-initialization-actions/jupyter/jupyter.sh
```

Note: RAPIDS init actions themselves do _not_ install Jupyter. In the example above, we *add* Jupyter from Dataproc's existing initialization actions:
```
gs://dataproc-initialization-actions/jupyter/jupyter.sh
```
at the end of your `--initialization-actions` argument. You'll usually want to configure it to use port 8888 as well by including the following metadata argument:
```
--metadata "JUPYTER_PORT=8888"
```


Also note, the `--bucket` argument tells Jupyter where to look for and save notebooks. If you don't supply a bucket argument, Dataproc will create a new bucket for you with a unique ID. Any changes you make to the notebooks in that bucket will persist across clusters. For this reason, we don't automatically include the [taxi notebook](https://github.com/randerzander/dataproc-initialization-actions/blob/master/rapids/notebooks/NYCTaxi-E2E.ipynb) example. You'll have to upload it to your Jupyter instance.

# Other Useful Info:

By default, Dataproc creates 2 "worker" VMs. In the example above, you'll get 4 T4s on the "master", and 4 each on your 2 workers, for a total of 12 GPUs, enough to run the full 3 years of taxi data in the notebook.

To specify more workers, you can use:
```
--num-workers $WORKER_COUNT
```

To use a single node, master-only cluster, use:
```
--single-node
```

# Delete a Cluster:

Given a cluster named "test"..

```
gcloud dataproc clusters delete test
```

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
ssh -i ~/.ssh/google_compute_engine -L 8888:localhost:8888 -L 8787:localhost:8787 ${YOUR_USERNAME}@${EXTERNAL_IP}
```
