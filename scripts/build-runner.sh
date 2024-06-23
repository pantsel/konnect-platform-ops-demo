#!/bin/bash
set -e

RUNNER_IMAGE="${RUNNER_IMAGE:-pantsel/gh-runner:latest}"

echo "Building the runner image: $RUNNER_IMAGE"

# Check if docker-squash is installed
if ! command -v docker-squash &> /dev/null
then
    echo "docker-squash could not be found. Please install it."
    echo "https://github.com/goldmann/docker-squash"
    exit 1
fi

# Build the Docker image
docker build --progress=plain --platform linux/amd64 --no-cache -t $RUNNER_IMAGE ./runner

# Squash the image to reduce its size
docker-squash -t $RUNNER_IMAGE $RUNNER_IMAGE