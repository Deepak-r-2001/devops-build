#!/usr/bin/env bash
set -euo pipefail

# Usage: ./build.sh [branch]
BRANCH=${1:-$(git rev-parse --abbrev-ref HEAD)}
DOCKERHUB_USER=${DOCKERHUB_USER:-deepwhoo}

IMAGE_DEV="${deepwhoo}/dev"
IMAGE_PROD="${deepwhoo}/prod"

COMMIT=$(git rev-parse --short HEAD)
TAG="$(date +%Y%m%d-%H%M%S)-${COMMIT}"

# Pick dev vs prod repo based on branch
if [[ "$BRANCH" == "master" || "$BRANCH" == "main" ]]; then
  IMAGE="$IMAGE_PROD"
else
  IMAGE="$IMAGE_DEV"
fi

echo ">> Building image: ${IMAGE}:${TAG} (and :latest)"

docker build \
  --build-arg VITE_BASE_URL="${VITE_BASE_URL:-}" \
  -t "${IMAGE}:${TAG}" \
  -t "${IMAGE}:latest" \
  .

echo ">> Done. Built: ${IMAGE}:${TAG}"
