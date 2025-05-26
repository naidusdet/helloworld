#!/bin/bash

set -e

APP_NAME=helloworld
DEPLOYMENT_NAME=helloworld-deployment

echo "🔄 Rebuilding Docker image..."
docker-compose down
docker-compose up --build -d   # Run in detached mode, so script continues

# Push the new image to the Docker registry
docker push maheshboyalla/helloworld:latest

echo "🚀 Restarting Kubernetes deployment..."
kubectl apply -f helloworld-config.yaml
kubectl apply -f helloworld-deployment.yaml
kubectl apply -f services.yaml
kubectl apply -f helloworld-ingress.yaml

# Restart Kubernetes deployment to pick up the new image
kubectl rollout restart deployment $DEPLOYMENT_NAME

echo "✅ Done. Current pods:"
kubectl get pods -l app=$APP_NAME
