#!/usr/bin/env bash

ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)
MASTER=$(/usr/share/google/get_metadata_value attributes/dataproc-master)
if [[ "${ROLE}" == 'Master' ]]; then
  dask-scheduler &
else
  dask-worker ${MASTER}:8786 &
fi
