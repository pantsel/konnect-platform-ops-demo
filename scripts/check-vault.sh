#!/bin/bash

if [[ -z "$VAULT_ADDR" ]]; then
    VAULT_ADDR="http://localhost:8300"
fi
MAX_RETRIES=10
RETRY_INTERVAL=5  # in seconds

check_vault_availability() {
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$VAULT_ADDR/v1/sys/health")
    if [[ $response -eq 200 ]]; then
        return 0  # Vault is available
    else
        return 1  # Vault is not available
    fi
}

retry=0
while [ $retry -lt $MAX_RETRIES ]; do
    if check_vault_availability; then
        echo "Vault is available."
        exit 0
    else
        echo "Vault is not yet available. Retrying in $RETRY_INTERVAL seconds..."
        sleep $RETRY_INTERVAL
        retry=$((retry + 1))
    fi
done

echo "Vault did not become available within the specified retries."
exit 1
