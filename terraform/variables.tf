variable "region" {
  description = "The AWS region to create resources in."
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name to use in resource names"
  default     = "generative-humans"
}

variable "availability_zones" {
  description = "Availability zones"
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "ecs_prod_backend_retention_days" {
  description = "Retention period for backend logs"
  default     = 30
}

# RDS
variable "prod_rds_db_name" {
  description = "RDS database name"
  default     = "gh_db"
}
variable "prod_rds_username" {
  description = "RDS database username"
  default     = "gh_dbu"
}
variable "prod_rds_password" {
  description = "postgres password for production DB"
}
variable "prod_rds_instance_class" {
  description = "RDS instance type"
  default     = "db.t4g.micro"
}

# nginx
variable "image_nginx" {
  description = "Docker image to run in the ECS cluster"
  default     = "770964512279.dkr.ecr.eu-central-1.amazonaws.com/nginx:latest"
}

# domain
variable "certificate_arn" {
  description = "AWS Certificate Manager ARN for generativehumans.org"
  default     = "arn:aws:acm:eu-central-1:770964512279:certificate/56dafd11-1d39-4e88-a8e1-490a340579c8"
}
