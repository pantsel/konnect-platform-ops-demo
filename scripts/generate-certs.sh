#!/bin/bash

set -e

# Set variables
CA_DIR=".tls"
CLIENT_DIR=".tls"
CA_KEY="$CA_DIR/ca.key"
CA_CERT="$CA_DIR/ca.crt"
CLIENT_CN="kong_clustering"
CLIENT_CN_PROXY="kong.proxy.local"
ORG="Kong"
ORG_UNIT="Kong-edu"
STATE="CA"
COUNTRY="US"

# Create directories
mkdir -p "$CA_DIR" "$CLIENT_DIR"

generate_ca() {
    if [ -f "$CA_KEY" ] && [ -f "$CA_CERT" ]; then
        if openssl x509 -checkend 0 -noout -in "$CA_CERT"; then
            echo "CA private key and certificate already exist and are valid."
            return
        else
            echo "CA certificate has expired. Regenerating..."
        fi
    fi

    echo "Generating CA private key and certificate..."
    # Generate CA private key
    openssl genpkey -algorithm RSA -out "$CA_KEY"

    # Generate CA self-signed certificate
    openssl req -new -x509 -key "$CA_KEY" -out "$CA_CERT" -subj "/CN=KonnectDemoCA/O=$ORG/OU=$ORG_UNIT/ST=$STATE/C=$COUNTRY"
}

generate_client_cert() {
    local client_key="$1"
    local client_csr="$2"
    local client_cert="$3"
    local client_cn="$4"

    # Generate client private key
    openssl genpkey -algorithm RSA -out "$client_key"

    # Generate client certificate signing request
    openssl req -new -key "$client_key" -out "$client_csr" -subj "/CN=$client_cn/O=$ORG/OU=$ORG_UNIT/ST=$STATE/C=$COUNTRY"

    # Sign client certificate with CA
    openssl x509 -req -in "$client_csr" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial -out "$client_cert" -days 365
}

# Generate CA
generate_ca

# Generate client certificates
generate_client_cert "$CLIENT_DIR/cluster-tls.key" "$CLIENT_DIR/cluster-tls.csr" "$CLIENT_DIR/cluster-tls.crt" "$CLIENT_CN"
generate_client_cert "$CLIENT_DIR/proxy-tls.key" "$CLIENT_DIR/proxy-tls.csr" "$CLIENT_DIR/proxy-tls.crt" "$CLIENT_CN_PROXY"

echo "Certificate Authority and Client certificates for $CLIENT_CN and $CLIENT_CN_PROXY generated successfully."
