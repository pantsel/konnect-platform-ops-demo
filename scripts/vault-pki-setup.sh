#!/bin/sh

set -e  # Exit immediately if a command exits with a non-zero status

# Define variables
VAULT_ADDR="${1:-http://127.0.0.1:8300}"
VAULT_TOKEN="${2:-root}"
GITHUB_ORG="${3:-null}"
PKI_MOUNT_PATH="pki"           
CERT_TTL="43800h" # 5 years               
COMMON_NAME_ROOT="ca.kong.edu.local"         
ROLE_NAME="kong"  
ROLE_ALLOWED_DOMAINS="kong.edu.local"
CERT_TTL_ROLE="4380h"

export VAULT_ADDR
export VAULT_TOKEN


# Function to enable PKI secrets engine
enable_pki() {
    if ! vault secrets list | grep -q "^${PKI_MOUNT_PATH}/"; then
        vault secrets enable -path=${PKI_MOUNT_PATH} -max-lease-ttl="${CERT_TTL}" pki
        echo "PKI secrets engine enabled at ${PKI_MOUNT_PATH}."
    else
        echo "PKI secrets engine already enabled at ${PKI_MOUNT_PATH}."
    fi
}

# Function to configure the root certificate
configure_root_cert() {
    if ! vault read -field=certificate ${PKI_MOUNT_PATH}/cert/ca > /dev/null 2>&1; then
        vault write ${PKI_MOUNT_PATH}/root/generate/internal \
            common_name="${COMMON_NAME_ROOT}" \
            ttl="${CERT_TTL}"
        echo "Root certificate generated for ${COMMON_NAME_ROOT}."
    else
        echo "Root certificate already exists."
    fi
}

# Function to configure the CA certificate endpoint
configure_ca_endpoint() {
    vault write ${PKI_MOUNT_PATH}/config/urls \
        issuing_certificates="${VAULT_ADDR}/v1/${PKI_MOUNT_PATH}/ca" \
        crl_distribution_points="${VAULT_ADDR}/v1/${PKI_MOUNT_PATH}/crl"
    echo "CA certificate endpoint configured."
}

# Function to create a role for issuing certificates
create_role() {
    vault write ${PKI_MOUNT_PATH}/roles/${ROLE_NAME} \
        allowed_domains=${ROLE_ALLOWED_DOMAINS} \
        allow_subdomains=true \
        max_ttl="${CERT_TTL_ROLE}"
    echo "Role ${ROLE_NAME} created."
}

configure_vault_github_auth() {
    if ! vault auth list | grep -q "^github/"; then
        vault auth enable github
        echo "GitHub auth method enabled."
    else
        echo "GitHub auth method already enabled."
        return
    fi

    if [ "${GITHUB_ORG}" = "null" ]; then
        echo "No GitHub organization provided. Skipping GitHub auth org configuration."
        return
    fi

    vault write auth/github/config organization=${GITHUB_ORG}
    echo "GitHub organization configured: ${GITHUB_ORG}."
}

# Main script execution
enable_pki
configure_root_cert
configure_ca_endpoint
create_role
configure_vault_github_auth
