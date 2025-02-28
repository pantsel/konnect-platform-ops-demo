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

# Prompt for optional github_org
read -p $'\n'"Enter GitHub organization (optional): " github_org
github_org=${github_org:-null}

read -s -p $'\n'"Enter konnect personal access token: " konnect_token
while [[ -z "$konnect_token" ]]; do
    read -s -p $'\n'"konnect personal access token cannot be empty. Please enter again: " konnect_token
done

read -s -p $'\n'"Enter s3 access key: " s3_access_key
while [[ -z "$s3_access_key" ]]; do
    read -s -p $'\n'"s3 access key cannot be empty. Please enter again: " s3_access_key
done

read -s -p $'\n'"Enter s3 secret key: " s3_secret_key
while [[ -z "$s3_secret_key" ]]; do
    read -s -p $'\n'"s3 secret key cannot be empty. Please enter again: " s3_secret_key
done

read -s -p $'\n'"Enter Docker username (default: _json_key): " docker_username
docker_username=${docker_username:-_json_key}

read -s -p $'\n'"Enter Docker password (default: secret): " docker_password
docker_password=${docker_password:-secret}

read -s -p $'\n'"Enter Vault token (default: root): " vault_token
vault_token=${vault_token:-root}

HOST_IP=$(./scripts/get-host-ip.sh)

read -s -p $'\n'"Enter OpenID Connect issuer (default: http://$HOST_IP:8080/realms/demo/.well-known/openid-configuration): " oidc_issuer
oidc_issuer=${oidc_issuer:-http://$HOST_IP:8080/realms/demo/.well-known/openid-configuration}

read -s -p $'\n'"Enter Datadog API key (optional): " dd_api_key

read -s -p $'\n'"Enter Dynatrace API token (optional): " dt_api_token

if [[ -z "$konnect_token" || -z "$s3_access_key" || -z "$s3_secret_key" ]]; then
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
S3_ACCESS_KEY=$s3_access_key
S3_SECRET_KEY=$s3_secret_key
DOCKER_USERNAME=$docker_username
DOCKER_PASSWORD=$docker_password
VAULT_TOKEN=$vault_token
OIDC_ISSUER=$oidc_issuer
DD_API_KEY=$dd_api_key
DT_API_TOKEN=$dt_api_token
KUBE_CONTEXT=$kube_context
EOF

if [[ "$github_org" != "null" ]]; then
    echo "GITHUB_ORG=$github_org" >> "$secret_file"
fi
