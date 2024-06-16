#!/usr/bin/env bash

docker buildx build --platform=linux/amd64 . -t 770964512279.dkr.ecr.eu-central-1.amazonaws.com/generative-humans-backend:latest
aws ecr get-login-password --region eu-central-1 --profile generative_humans | docker login --username AWS --password-stdin 770964512279.dkr.ecr.eu-central-1.amazonaws.com
docker push 770964512279.dkr.ecr.eu-central-1.amazonaws.com/generative-humans-backend:latest

cd terraform && terraform apply -auto-approve

# Collect ECS_GROUP_ID and PRIVATE_SUBNET_ID for running migrations
ECS_GROUP_ID=$(aws ec2 describe-security-groups --region eu-central-1 --profile generative_humans --filters Name=group-name,Values=prod-ecs-backend --query "SecurityGroups[*][GroupId]" --output text)
PRIVATE_SUBNET_ID=$(aws ec2 describe-subnets --region eu-central-1 --profile generative_humans  --filters "Name=tag:Name,Values=prod-private-1" --query "Subnets[*][SubnetId]"  --output text)

echo "Running migration task..."

# Construct NETWORK_CONFIGURATON to run migtaion task 
NETWORK_CONFIGURATON="{\"awsvpcConfiguration\": {\"subnets\": [\"${PRIVATE_SUBNET_ID}\"], \"securityGroups\": [\"${ECS_GROUP_ID}\"],\"assignPublicIp\": \"DISABLED\"}}"

# Start migration task
MIGRATION_TASK_ARN=$(aws ecs run-task --region eu-central-1 --profile generative_humans --cluster prod --task-definition backend-migration --count 1 --launch-type FARGATE --network-configuration "${NETWORK_CONFIGURATON}" --query 'tasks[*][taskArn]' --output text)

echo "Task ${MIGRATION_TASK_ARN} running..."

# Wait migration task to complete
aws ecs wait tasks-stopped --region eu-central-1 --profile generative_humans --cluster prod --tasks "${MIGRATION_TASK_ARN}"

echo "Running collectstatic task..."

# Start collectstatic task
COLLECTSTATIC_TASK_ARN=$(aws ecs run-task --region eu-central-1 --profile generative_humans --cluster prod --task-definition backend-collectstatic --count 1 --launch-type FARGATE --network-configuration "${NETWORK_CONFIGURATON}" --query 'tasks[*][taskArn]' --output text)

echo "Task ${COLLECTSTATIC_TASK_ARN} running..."

# Wait collectstatic task to complete
aws ecs wait tasks-stopped --region eu-central-1 --profile generative_humans --cluster prod --tasks "${COLLECTSTATIC_TASK_ARN}"

# Restart service
aws ecs update-service --profile generative_humans --region eu-central-1 --cluster prod --service prod-backend-web --force-new-deployment --query "service.serviceName" --output json
