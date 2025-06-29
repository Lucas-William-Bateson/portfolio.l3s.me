#!/bin/bash

# Safe cleanup script for portfolio app only
set -e

echo "🧹 Cleaning up portfolio-specific resources..."

# Stop and remove only portfolio containers
echo "Stopping portfolio containers..."
docker compose -f docker-compose.prod.yml down

# Remove old portfolio images (keep last 3 versions)
echo "Cleaning up old portfolio images..."
IMAGES_TO_DELETE=$(docker images localhost:5001/portfolio --format "table {{.Repository}}:{{.Tag}}\t{{.CreatedAt}}" | tail -n +2 | head -n -3 | awk '{print $1}')
if [ ! -z "$IMAGES_TO_DELETE" ]; then
    echo "Removing old portfolio images:"
    echo "$IMAGES_TO_DELETE"
    echo "$IMAGES_TO_DELETE" | xargs docker rmi || true
else
    echo "No old portfolio images to remove"
fi

# Clean up dangling images with portfolio label only
echo "Cleaning up dangling portfolio images..."
docker image prune -f --filter "label=app=portfolio"

# Clean up unused portfolio networks
echo "Cleaning up unused portfolio networks..."
docker network ls --filter "label=app=portfolio" --format "{{.Name}}" | grep -v "portfolio_network" | xargs -r docker network rm || true

echo "✅ Portfolio cleanup completed safely"
echo "Other applications on this Docker instance were not affected"

# Show remaining portfolio resources
echo ""
echo "📊 Remaining portfolio resources:"
echo "Images:"
docker images localhost:5001/portfolio
echo ""
echo "Containers:"
docker ps -a --filter "label=app=portfolio"
echo ""
echo "Networks:"
docker network ls --filter "label=app=portfolio"
