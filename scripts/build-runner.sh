#!/bin/bash
set -e

RUNNER_IMAGE="${RUNNER_IMAGE:-pantsel/gh-runner:latest}"

echo "Building the runner image: $RUNNER_IMAGE"

# Build the Docker image
docker build --progress=plain --platform linux/amd64 --no-cache -t $RUNNER_IMAGE ./runner