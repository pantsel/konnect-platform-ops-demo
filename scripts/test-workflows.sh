#!/bin/bash

set -e

# Prepare the environment for federated tests
# make prepare

# Build Kong image
echo "++++++ BEGIN BUILD IMAGE +++++"
act -W .github/workflows/build-image.yaml
echo "++++++ SUCCESS BUILD IMAGE +++++"

# Proviosion static
# act -W .github/workflows/provision-konnect-static.yaml 

# Create teams
echo "++++++ BEGIN CREATE TEAMS +++++"
act --input config=./examples/platformops/federated/teams/teams.json -W .github/workflows/onboard-konnect-teams.yaml
echo "++++++ SUCCESS CREATE TEAMS +++++"

# Onboard Kronos team
echo "++++++ BEGIN ONBOARD KRONOS +++++"
act --input config=./examples/platformops/federated/teams/kronos/resources.json -W .github/workflows/provision-konnect-team-resources.yaml
echo "++++++ SUCCESS ONBOARD KRONOS +++++"

# Deploy DP for Kronos CPG
echo "++++++ BEGIN DEPLOY DP +++++"
act --input control_plane_name="Control Plane Group Kronos" --input system_account=sa-control-plane-group-kronos-cp-admin  -W .github/workflows/deploy-dp.yaml
echo "++++++ SUCCESS DEPLOY DP +++++"

# Wait for the DP to be ready --> this needs to be more flexible
echo "++++++ BEGIN WAIT FOR DP TO BE AVAILABLE +++++"
kubectl wait --for=condition=available deployment/kong-dp-control-plane-group-kronos-kong -n kong --timeout=300s
echo "++++++ SUCCESS WAIT FOR DP TO BE AVAILABLE +++++"

# # Deploy datadog observability stack
# act --input control_plane_name="Kronos Dev" --input observability_stack=datadog -W .github/workflows/deploy-observability-tools.yaml

# Deploy API
echo "++++++ BEGIN DEPLOY API +++++"
act --input action=deploy --input observability_stack=datadog -W .github/workflows/deploy-api.yaml
echo "++++++ SUCCESS DEPLOY API +++++"

# Promote API
echo "++++++ BEGIN PROMOTE API +++++"
act --input openapi_spec=examples/apiops/apis/petstore/oas.yaml --input control_plane_name="Kronos Dev" --input system_account="sa-kronos-dev-cp-admin" -W .github/workflows/promote-api.yaml
echo "++++++ SUCCESS PROMOTE API +++++"

# Wait 10 seconds for changes to propagate
sleep 10

# Test the API --> this needs to be adapted to support orb k8s and kind
# http -a demo:h2f8jgfkUclMa8GEmxJWNxOp00yzF6Wv k8s.orb.local/petstore/pets | jq

# Deploy API
echo "++++++ BEGIN DESTROY API +++++"
act --input action=destroy --input observability_stack=datadog -W .github/workflows/deploy-api.yaml
echo "++++++ SUCCESS DESTROY API +++++"

# Destroy DP
echo "++++++ BEGIN DESTROY DP +++++"
act --input action=destroy --input control_plane_name="Control Plane Group Kronos" --input system_account=sa-control-plane-group-kronos-cp-admin  -W .github/workflows/deploy-dp.yaml
echo "++++++ SUCCESS DESTROY DP +++++"

# Destroy observability stack
# echo "++++++ BEGIN DESTROY OBSERVABILITY +++++"
# act --input action=destroy --input control_plane_name="Kronos Dev" --input observability_stack=datadog -W .github/workflows/deploy-observability-tools.yaml
# echo "++++++ SUCCESS DESTROY OBSERVABILITY +++++"

# Deprovision Kronos team
echo "++++++ BEGIN DEPROVISION KRONOS +++++"
act --input action=destroy --input config=./examples/platformops/federated/teams/kronos/resources.json -W .github/workflows/provision-konnect-team-resources.yaml
echo "++++++ SUCCESS DEPROVISION KRONOS +++++"

# make clean
