#!/usr/bin/env bash

TASK_ID=$(aws ecs list-tasks --cluster prod --profile generative_humans --region=eu-central-1 --service-name prod-backend-web --query 'taskArns[0]' --output text | awk '{split($0,a,"/"); print a[3]}')
aws ecs execute-command --task $TASK_ID --profile generative_humans --command "bash" --interactive --cluster prod --region eu-central-1
