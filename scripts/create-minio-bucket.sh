#!/bin/bash

# Define your bucket name and alias
ALIAS=$1
BUCKET_NAME=$2

# Check if the bucket exists
if mc ls "${ALIAS}/${BUCKET_NAME}" &> /dev/null; then
    echo "Bucket ${BUCKET_NAME} already exists."
else
    # Create the bucket if it does not exist
    mc mb "${ALIAS}/${BUCKET_NAME}"
    if [ $? -eq 0 ]; then
        echo "Bucket ${BUCKET_NAME} created successfully."
    else
        echo "Failed to create bucket ${BUCKET_NAME}."
    fi
fi