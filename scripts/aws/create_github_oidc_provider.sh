#!/bin/bash

# Set AWS account variables
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
OIDC_PROVIDER_URL="https://token.actions.githubusercontent.com"
OIDC_PROVIDER_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
THUMBPRINT="6938fd4d98bab03faadb97b34396831e3780aea1"

# Function to check if OIDC provider exists
function oidc_provider_exists() {
    aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[*].Arn" --output text | grep -q "$OIDC_PROVIDER_ARN"
}

# Create the OIDC provider if it doesn't exist
if oidc_provider_exists; then
    echo "✅ GitHub OIDC provider already exists in AWS IAM."
else
    echo "🚀 Creating GitHub OIDC provider..."
    aws iam create-open-id-connect-provider \
        --url "$OIDC_PROVIDER_URL" \
        --client-id-list "sts.amazonaws.com" \
        --thumbprint-list "$THUMBPRINT"

    if [ $? -eq 0 ]; then
        echo "✅ GitHub OIDC provider successfully created!"
    else
        echo "❌ Failed to create GitHub OIDC provider."
        exit 1
    fi
fi
