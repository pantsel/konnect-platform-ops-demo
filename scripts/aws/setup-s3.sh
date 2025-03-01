#!/bin/bash

BUCKET_NAME="konnect.teams"
REGION="eu-central-1"

# Check if the bucket exists (silent check)
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>&1 | grep -q 'Not Found'; then
    echo "Bucket does not exist. Creating..."
    
    # Create the bucket
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION" >/dev/null 2>&1
    
    # Enable versioning (Optional)
    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled >/dev/null 2>&1
    
    echo "Bucket '$BUCKET_NAME' created successfully."
else
    echo "Bucket '$BUCKET_NAME' already exists. No action needed."
fi
