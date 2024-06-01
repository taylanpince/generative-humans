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
