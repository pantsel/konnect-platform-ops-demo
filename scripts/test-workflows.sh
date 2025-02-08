#!/bin/bash

set -e

# Prepare the environment for federated tests
make prepare

# Build Kong image
act -W .github/workflows/build-image.yaml

# Onboard Kronos team
act --input config=./examples/platformops/federated/kronos-team.json -W .github/workflows/provision-konnect.yaml

# Deploy DP
act --input control_plane_name="Kronos Dev" --input system_account=sa-kronos-dev-cp-admin  -W .github/workflows/deploy-dp.yaml

# Wait for the DP to be ready
kubectl wait --for=condition=available deployment/kong-dp-kronos-dev-kong -n kong --timeout=300s

# Deploy datadog observability stack
act --input control_plane_name="Kronos Dev" --input observability_stack=datadog -W .github/workflows/deploy-observability-tools.yaml

# Deploy API
act --input action=deploy --input observability_stack=datadog -W .github/workflows/deploy-api.yaml

# Promote API
act --input openapi_spec=examples/apiops/apis/petstore/oas.yaml --input control_plane_name="Kronos Dev" --input system_account="sa-kronos-dev-cp-admin" -W .github/workflows/promote-api.yaml

# Wait 10 seconds for changes to propagate
sleep 10

# Test the API
http -a demo:h2f8jgfkUclMa8GEmxJWNxOp00yzF6Wv k8s.orb.local/petstore/pets | jq


# Destroy DP
act --input action=destroy --input control_plane_name="Kronos Dev" --input system_account=sa-kronos-dev-cp-admin  -W .github/workflows/deploy-dp.yaml

# Destroy observability stack
act --input action=destroy --input control_plane_name="Kronos Dev" --input observability_stack=datadog -W .github/workflows/deploy-observability-tools.yaml

# Deprovision Kronos team
act --input action=destroy --input config=./examples/platformops/federated/kronos-team.json -W .github/workflows/provision-konnect.yaml


# make clean
