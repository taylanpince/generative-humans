# Production cluster
resource "aws_ecs_cluster" "prod" {
  name = "prod"
}

# Local variables
locals {
  container_vars = {
    region = var.region

    image     = aws_ecr_repository.backend.repository_url
    log_group = aws_cloudwatch_log_group.prod_backend.name
    log_stream_nginx = aws_cloudwatch_log_stream.nginx.name

    rds_db_name  = var.prod_rds_db_name
    rds_username = var.prod_rds_username
    rds_password = var.prod_rds_password
    rds_hostname = aws_db_instance.prod.address
    image_nginx  = var.image_nginx

    s3_media_bucket         = var.prod_media_bucket
    s3_access_key           = aws_iam_access_key.prod_media_bucket.id
    s3_secret_key           = aws_iam_access_key.prod_media_bucket.secret

    ses_access_key          = aws_iam_access_key.smtp_user.id
    ses_secret_key          = aws_iam_access_key.smtp_user.secret
  }
}

# Backend web task definition and service
resource "aws_ecs_task_definition" "prod_backend_web" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  family = "backend-web"
  container_definitions = templatefile(
    "templates/backend_container.json.tpl",
    merge(
      local.container_vars,
      {
        name         = "prod-backend-web"
        command      = ["gunicorn", "-w", "3", "-b", ":8001", "generative_humans.wsgi:application"]
        log_stream   = aws_cloudwatch_log_stream.prod_backend_web.name
      }
    )
  )
  
  execution_role_arn     = aws_iam_role.ecs_task_execution.arn
  task_role_arn          = aws_iam_role.prod_backend_task.arn

  volume {
    name = "efs-volume"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        access_point_id = aws_efs_access_point.app_access_point.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "prod_backend_web" {
  name                               = "prod-backend-web"
  cluster                            = aws_ecs_cluster.prod.id
  task_definition                    = aws_ecs_task_definition.prod_backend_web.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  enable_execute_command             = true

  load_balancer {
    target_group_arn = aws_lb_target_group.prod_backend.arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    security_groups  = [aws_security_group.prod_ecs_backend.id]
    subnets          = [aws_subnet.prod_private_1.id, aws_subnet.prod_private_2.id]
    assign_public_ip = false
  }
}

# Security Group
resource "aws_security_group" "prod_ecs_backend" {
  name        = "prod-ecs-backend"
  vpc_id      = aws_vpc.prod.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.prod_lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM roles and policies
resource "aws_iam_role" "prod_backend_task" {
  name = "prod-backend-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })

  inline_policy {
    name = "prod-backend-task-ssmmessages"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          },
          Effect = "Allow",
          Sid    = ""
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Cloudwatch Logs
resource "aws_cloudwatch_log_group" "prod_backend" {
  name              = "prod-backend"
  retention_in_days = var.ecs_prod_backend_retention_days
}

resource "aws_cloudwatch_log_stream" "prod_backend_web" {
  name           = "prod-backend-web"
  log_group_name = aws_cloudwatch_log_group.prod_backend.name
}

resource "aws_cloudwatch_log_stream" "nginx" {
  name           = "nginx"
  log_group_name = aws_cloudwatch_log_group.prod_backend.name
}

resource "aws_cloudwatch_log_stream" "prod_backend_migrations" {
  name           = "prod-backend-migrations"
  log_group_name = aws_cloudwatch_log_group.prod_backend.name
}

resource "aws_cloudwatch_log_stream" "prod_backend_collectstatic" {
  name           = "prod-backend-collectstatic"
  log_group_name = aws_cloudwatch_log_group.prod_backend.name
}

# DB Migration task definition
resource "aws_ecs_task_definition" "prod_backend_migration" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  family = "backend-migration"
  container_definitions = templatefile(
    "templates/backend_container.json.tpl",
    merge(
      local.container_vars,
      {
        name       = "prod-backend-migration"
        command    = ["python", "manage.py", "migrate"]
        log_stream = aws_cloudwatch_log_stream.prod_backend_migrations.name
      },
    )
  )
  
  depends_on         = [aws_db_instance.prod]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.prod_backend_task.arn

  volume {
    name = "efs-volume"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        access_point_id = aws_efs_access_point.app_access_point.id
        iam             = "ENABLED"
      }
    }
  }
}

# collectstatic task definition
resource "aws_ecs_task_definition" "prod_backend_collectstatic" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  family = "backend-collectstatic"
  container_definitions = templatefile(
    "templates/backend_container.json.tpl",
    merge(
      local.container_vars,
      {
        name       = "prod-backend-collectstatic"
        command    = ["python", "manage.py", "collectstatic", "--noinput"]
        log_stream = aws_cloudwatch_log_stream.prod_backend_collectstatic.name
      },
    )
  )
  
  depends_on         = [aws_db_instance.prod]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.prod_backend_task.arn

  volume {
    name = "efs-volume"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        access_point_id = aws_efs_access_point.app_access_point.id
        iam             = "ENABLED"
      }
    }
  }
}

# EFS
resource "aws_efs_file_system" "efs" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_access_point" "app_access_point" {
  file_system_id = aws_efs_file_system.efs.id
  posix_user {
    uid = 1000
    gid = 1000
  }
  root_directory {
    path = "/efs"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  count           = length([aws_subnet.prod_public_1.id, aws_subnet.prod_public_2.id])
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = [aws_subnet.prod_public_1.id, aws_subnet.prod_public_2.id][count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_security_group" "efs_sg" {
  name        = "EFS Security Group"
  description = "Allow ECS to EFS communication"
  vpc_id      = aws_vpc.prod.id

  ingress {
    from_port   = 2049  # NFS port
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Modify this based on your security requirements
  }
}
