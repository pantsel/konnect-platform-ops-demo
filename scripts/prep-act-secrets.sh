#!/bin/bash

set -e

secret_file="act.secrets"

if [[ -f "$secret_file" ]]; then
    echo "$secret_file file already exists."
    exit 0
fi

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

if [[ -z "$konnect_token" || -z "$s3_access_key" || -z "$s3_secret_key" ]]; then
    echo $'\n'"One or more variables are empty. Exiting..."
    exit 1
fi

cat << EOF > "$secret_file"
KONNECT_PAT=$konnect_token
S3_ACCESS_KEY=$s3_access_key
S3_SECRET_KEY=$s3_secret_key
DOCKER_USERNAME=$docker_username
DOCKER_PASSWORD=$docker_password
VAULT_TOKEN=$vault_token
OIDC_ISSUER=$oidc_issuer
DD_API_KEY=$dd_api_key
EOF
