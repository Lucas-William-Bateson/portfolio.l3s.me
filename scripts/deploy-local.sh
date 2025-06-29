#!/bin/bash

# Build and deploy script for testing
set -e

echo "Building Docker image..."
IMAGE_TAG="test-$(date +%s)"
NAME="portfolio"

# Build the image
docker build -t localhost:5001/${NAME}:${IMAGE_TAG} .

echo "Built image: localhost:5001/${NAME}:${IMAGE_TAG}"

# Export the image tag for docker-compose
export IMAGE_TAG=${IMAGE_TAG}

echo "Stopping existing containers..."
docker compose -f docker-compose.prod.yml down || true

echo "Starting new deployment..."
docker compose -f docker-compose.prod.yml up -d

echo "Waiting for container to start..."
sleep 5

echo "Checking container status..."
docker compose -f docker-compose.prod.yml ps

echo "Testing if site is accessible..."
if curl -f http://localhost:5080 > /dev/null 2>&1; then
    echo "✅ Site is accessible at http://localhost:5080"
else
    echo "❌ Site is not accessible"
    echo "Container logs:"
    docker compose -f docker-compose.prod.yml logs
fi
