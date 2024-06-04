#!/bin/bash

set -e

# Set variables
CA_DIR=".tls"
CLIENT_DIR=".tls"
CA_KEY="$CA_DIR/ca.key"
CA_CERT="$CA_DIR/ca.crt"
CLIENT_KEY="$CLIENT_DIR/tls.key"
CLIENT_CSR="$CLIENT_DIR/tls.csr"
CLIENT_CERT="$CLIENT_DIR/tls.crt"
CLIENT_CN="kong_dp"

# Create directories
mkdir -p "$CA_DIR" "$CLIENT_DIR"

# Generate CA private key and certificate if they don't exist
if [ -f "$CA_KEY" ] && [ -f "$CA_CERT" ]; then
    echo "CA private key and certificate already exist."
else
    echo "Generating CA private key and certificate..."
    # Generate CA private key
    openssl genpkey -algorithm RSA -out "$CA_KEY"

    # Generate CA self-signed certificate
    openssl req -new -x509 -key "$CA_KEY" -out "$CA_CERT" -subj "/CN=KonnectDemoCA"
fi


# Generate client private key
openssl genpkey -algorithm RSA -out "$CLIENT_KEY"

# Generate client certificate signing request
openssl req -new -key "$CLIENT_KEY" -out "$CLIENT_CSR" -subj "/CN=$CLIENT_CN"

# Sign client certificate with CA
openssl x509 -req -in "$CLIENT_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial -out "$CLIENT_CERT" -days 365

echo "Certificate Authority and Client certificates generated successfully."