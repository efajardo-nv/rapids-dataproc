#!/usr/bin/env bash

ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)
MASTER=$(/usr/share/google/get_metadata_value attributes/dataproc-master)

if [[ "${ROLE}" == 'Master' ]]; then
  dask-scheduler > /var/log/dask-scheduler.log 2>&1 &
else
  dask-cuda-worker --memory-limit 0 ${MASTER}:8786 > /var/log/dask-cuda-worker.log 2>&1 &
fi
