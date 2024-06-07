#!/bin/bash

set -e

# Define your bucket name and alias
ALIAS=$1
BUCKET_NAME=$2
ROOT_USER="${3:-minio-root-user}"
ROOT_PASSWORD="${4:-minio-root-password}"
MINIO_URL="${5:-http://localhost:9000}"

mc alias set $ALIAS $MINIO_URL $ROOT_USER $ROOT_PASSWORD

# Check if the bucket exists
if mc ls "${ALIAS}/${BUCKET_NAME}" &> /dev/null; then
    echo "Bucket ${BUCKET_NAME} already exists."
    exit 0
else
    # Create the bucket if it does not exist
    mc mb "${ALIAS}/${BUCKET_NAME}"
    if [ $? -eq 0 ]; then
        echo "Bucket ${BUCKET_NAME} created successfully."
        exit 0
    else
        echo "Failed to create bucket ${BUCKET_NAME}."
        exit 1
    fi
fi