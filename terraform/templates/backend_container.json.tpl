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
    "mountPoints": [
      {
        "containerPath": "/efs/staticfiles/",
        "sourceVolume": "efs-volume",
        "readOnly": false

      }
    ],
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
  },
  {
    "name": "nginx",
    "image": "${image_nginx}",
    "essential": true,
    "cpu": 10,
    "memory": 128,
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/efs/staticfiles/",
        "sourceVolume": "efs-volume",
        "readOnly": false

      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "${log_stream_nginx}"
      }
    }
  }
]