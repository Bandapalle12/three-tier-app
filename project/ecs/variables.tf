variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "three-tier-demo"
}

variable "docker_image" {
  description = "Docker image for ECS service"
  type        = string
  default     = "487527603832.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest"
}

variable "app_port" {
  description = "App container port"
  type        = number
  default     = 3000
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "rds_host" {
  type = string
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
} 

variable "rds_secret_arn" {
  description = "ARN of Secrets Manager secret with RDS credentials"
  type        = string
  default     = ""
}
variable "rds_secret_name" {
description = "Name (or ARN) of existing Secrets Manager secret for RDS credentials"
type = string
default = ""
}