ID=$1

gcloud compute --project "nv-ai-infra" ssh --zone "us-east1-c" "$ID"
