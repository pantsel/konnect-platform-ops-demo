#!/bin/bash

set -e

secret_file="act.secrets"

if [[ -f "$secret_file" ]]; then
    echo "$secret_file file already exists."
    exit 0
fi

if ! command -v gh &> /dev/null; then
    echo $'\n'"GitHub CLI not found. Please enter your GitHub token."
    read -s -p $'\n'"Enter GitHub token: " GITHUB_TOKEN
    while [[ -z "$GITHUB_TOKEN" ]]; do
        read -s -p $'\n'"GitHub token cannot be empty. Please enter again: " GITHUB_TOKEN
    done
else
    GITHUB_TOKEN=$(gh auth token 2>/dev/null || true)
    if [[ $? -ne 0 || -z "$GITHUB_TOKEN" ]]; then
        echo $'\n'"GitHub token not found or user not logged in. Attempting to log in..."
        gh auth login
        GITHUB_TOKEN=$(gh auth token 2>/dev/null)
        if [[ -z "$GITHUB_TOKEN" ]]; then
            read -s -p $'\n'"Enter GitHub token: " GITHUB_TOKEN
            while [[ -z "$GITHUB_TOKEN" ]]; do
                read -s -p $'\n'"GitHub token cannot be empty. Please enter again: " GITHUB_TOKEN
            done
        else
            echo $'\n'"Using GitHub token from gh auth."
        fi
    else
        echo $'\n'"Using GitHub token from gh auth."
    fi
fi

# AWS credentials file path
AWS_CREDENTIALS_FILE="$HOME/.aws/credentials"

if [[ -f "$AWS_CREDENTIALS_FILE" ]]; then

    # Extract profile names from the credentials file
    PROFILES=($(grep '^\[' "$AWS_CREDENTIALS_FILE" | tr -d '[]'))

    # Check if profiles were found
    if [[ ${#PROFILES[@]} -eq 0 ]]; then
        echo "No AWS profiles found in $AWS_CREDENTIALS_FILE"
        exit 1
    fi

    # Display available profiles in a numbered list
    echo "Available AWS profiles:"
    for i in "${!PROFILES[@]}"; do
        echo "$((i+1))) ${PROFILES[$i]}"
    done

    # Prompt user to select a profile using numbers
    while true; do
        read -rp "Select a profile by entering its number: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#PROFILES[@]} )); then
            SELECTED_PROFILE="${PROFILES[$((choice-1))]}"
            break
        else
            echo "Invalid selection. Please enter a valid number."
        fi
    done

    # Extract AWS credentials for the selected profile
    aws_access_key_id=$(awk -v profile="[$SELECTED_PROFILE]" '
        $0 == profile { found=1; next }
        found && /aws_access_key_id/ { print $3; found=0 }
    ' "$AWS_CREDENTIALS_FILE")

    aws_secret_access_key=$(awk -v profile="[$SELECTED_PROFILE]" '
        $0 == profile { found=1; next }
        found && /aws_secret_access_key/ { print $3; found=0 }
    ' "$AWS_CREDENTIALS_FILE")
fi

# Prompt for github_org
org=$(git remote get-url origin | sed -E 's#.*github.com[:/](.*)/.*#\1#' )
read -p $'\n'"Enter GitHub owner (default: $org): " github_org
github_org=${github_org:-$org}

read -s -p $'\n'"Enter konnect personal access token: " konnect_token
while [[ -z "$konnect_token" ]]; do
    read -s -p $'\n'"konnect personal access token cannot be empty. Please enter again: " konnect_token
done

read -s -p $'\n'"Enter Datadog API key (optional): " dd_api_key

read -s -p $'\n'"Enter Dynatrace API token (optional): " dt_api_token

if [[ -z "$konnect_token" || -z "$aws_access_key_id" || -z "$aws_secret_access_key" ]]; then
    echo $'\n'"One or more variables are empty. Exiting..."
    exit 1
fi

read -s -p $'\n'"Enter K8s engine (orbstack/kind, default: orbstack): " kube_context
while [[ "$kube_context" != "orbstack" && "$kube_context" != "kind" && -n "$kube_context" ]]; do
    read -s -p $'\n'"Invalid input. Please enter 'orbstack' or 'kind' (default: orbstack): " kube_context
done
kube_context=${kube_context:-orbstack}

cat << EOF > "$secret_file"
KONNECT_PAT=$konnect_token
GITHUB_TOKEN=$GITHUB_TOKEN
AWS_ACCESS_KEY_ID=$aws_access_key_id
AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
GITHUB_ORG=$github_org
DD_API_KEY=$dd_api_key
DT_API_TOKEN=$dt_api_token
KUBE_CONTEXT=$kube_context
EOF