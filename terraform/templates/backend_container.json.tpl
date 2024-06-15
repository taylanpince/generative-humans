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
      },
      {
        "name": "AWS_ACCESS_KEY_ID",
        "value": "${s3_access_key}"
      },
      {
        "name": "AWS_SECRET_ACCESS_KEY",
        "value": "${s3_secret_key}"
      },
      {
        "name": "AWS_STORAGE_BUCKET_NAME",
        "value": "${s3_media_bucket}"
      },
      {
        "name": "AWS_S3_REGION_NAME",
        "value": "${region}"
      },
      {
       "name": "AWS_S3_ENDPOINT_URL",
       "value": "https://${s3_media_bucket}.s3.${region}.amazonaws.com/"
      },
      {
        "name": "AWS_SES_ACCESS_KEY_ID",
        "value": "${ses_access_key}"
      },
      {
        "name": "AWS_SES_SECRET_ACCESS_KEY",
        "value": "${ses_secret_key}"
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