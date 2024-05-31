#!/bin/bash
set -e

namespace="kong"
control_plane_endpoint=$1
telemetry_endpoint=$2

echo "Deploying Kong Data Plane"
echo "========================="
echo "Namespace: $namespace"
echo "Control Plane Endpoint: $control_plane_endpoint"
echo "Telemetry endpoint: $telemetry_endpoint"
echo "========================="

# Create Kong namespace
kubectl create namespace $namespace --dry-run=client -o yaml | kubectl apply -f -

# Create secret for Kong cluster certificate
kubectl create secret tls kong-cluster-cert \
    -n $namespace \
    --dry-run=client \
    --cert=./.tls/tls.crt --key=./.tls/tls.key -o yaml \
    | kubectl apply -f -


helm upgrade --install kong-dp kong/kong \
    -n $namespace --create-namespace \
    --values ./k8s/values.yaml \
    --set env.cluster_control_plane=$control_plane_endpoint:443 \
    --set env.cluster_server_name=$control_plane_endpoint \
    --set env.cluster_telemetry_endpoint=$telemetry_endpoint:443 \
    --set env.cluster_telemetry_server_name=$telemetry_endpoint \
    --set env.cluster_cert=/etc/secrets/kong-cluster-cert/tls.crt \
    --set env.cluster_cert_key=/etc/secrets/kong-cluster-cert/tls.key