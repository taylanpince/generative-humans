#!/usr/bin/env bash

docker buildx build --platform=linux/amd64 . -t 770964512279.dkr.ecr.eu-central-1.amazonaws.com/nginx:latest
aws ecr get-login-password --region eu-central-1 --profile generative_humans | docker login --username AWS --password-stdin 770964512279.dkr.ecr.eu-central-1.amazonaws.com
docker push 770964512279.dkr.ecr.eu-central-1.amazonaws.com/nginx:latest
