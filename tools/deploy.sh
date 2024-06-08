#!/usr/bin/env bash

docker buildx build --platform=linux/amd64 . -t 770964512279.dkr.ecr.eu-central-1.amazonaws.com/generative-humans-backend:latest
aws ecr get-login-password --region eu-central-1 --profile generative_humans | docker login --username AWS --password-stdin 770964512279.dkr.ecr.eu-central-1.amazonaws.com
docker push 770964512279.dkr.ecr.eu-central-1.amazonaws.com/generative-humans-backend:latest

cd terraform && terraform apply -auto-approve

aws ecs update-service --profile generative_humans --region eu-central-1 --cluster prod --service prod-backend-web --force-new-deployment --query "service.serviceName" --output json
