variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "three-tier-demo"
}

variable "docker_image" {
  description = "Docker image for ECS service"
  type        = string
  default     = "bandapalle12/hello-world:latest"
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
