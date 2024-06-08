[
  {
    "name": "${name}",
    "image": "${image}",
    "essential": true,
    "links": [],
    "portMappings": [
      {
        "containerPort": 8001,
        "hostPort": 8001,
        "protocol": "tcp"
      }
    ],
    "command": ${jsonencode(command)},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "${log_stream}"
      }
    },
    "environment": [
      {
        "name": "DATABASE_USERNAME",
        "value": "${rds_username}"
      },
      {
        "name": "DATABASE_PASSWORD",
        "value": "${rds_password}"
      },
      {
        "name": "DATABASE_HOSTNAME",
        "value": "${rds_hostname}"
      },
      {
        "name": "DATABASE_DB_NAME",
        "value": "${rds_db_name}"
      },
      {
        "name": "DJANGO_SETTINGS_MODULE",
        "value": "generative_humans.settings.production"
      }
    ]
  }
]