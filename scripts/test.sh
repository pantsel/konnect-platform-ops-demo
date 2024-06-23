#!/bin/bash

set -e

# Prepare the environment for federated tests
make prepare

# Onboard Kronos team
act --input config_file=examples/platformops/federated/kronos-team.json \
  -W .github/workflows/provision-konnect-federated.yaml 

echo "Waiting for 10 seconds for changes to propagate..."
sleep 10

# Deploy DP
act --input control_plane_name=kronos_cp_dev \
    --input system_account=npa_kronos_kronos_cp_dev \
    -W .github/workflows/deploy-dp.yaml

# Promote API
act --input openapi_spec=examples/apiops/openapi.yaml \
    --input control_plane_name=kronos_cp_dev \
    --input system_account=npa_kronos_kronos_cp_dev  \
    -W .github/workflows/promote-api.yaml

nohup kubectl port-forward \
    deployment/kong-dp-kronos-cp-dev-kong \
    8000:8000 -n kong > port-forward.log 2>&1 &  

# Get the PID of the background process
PID=$!

# Print the PID to the console
echo "Port forwarding started in the background with PID: $PID"
echo "Logs are being written to port-forward.log"

echo "Waiting for 10 seconds for changes to propagate..."
sleep 10

# Test the API
http -a demo:h2f8jgfkUclMa8GEmxJWNxOp00yzF6Wv :8000/petstore/pets | jq

# Kill the port-forward process
kill $PID 

# Deprovision Kronos team
act --input config_file=examples/platformops/federated/kronos-team.json \
    --input action=destroy \
    -W .github/workflows/provision-konnect-federated.yaml 

make clean
