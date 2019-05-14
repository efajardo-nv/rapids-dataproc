DATAPROC_BUCKET=$1

# run from https://github.com/randerzander/dataproc-initialization-actions/tree/master/rapids
gsutil cp *.sh gs://$DATAPROC_BUCKET/rapids/
gsutil cp *.yml gs://$DATAPROC_BUCKET/rapids/
