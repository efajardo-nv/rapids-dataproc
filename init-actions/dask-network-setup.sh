#!/usr/bin/env bash

ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)
MASTER=$(/usr/share/google/get_metadata_value attributes/dataproc-master)

if [[ "${ROLE}" == 'Master' ]]; then
  dask-scheduler &
else
  dask-cuda-worker --memory-limit 0 ${MASTER}:8786 2>&1 &> /var/log/worker.log
fi
