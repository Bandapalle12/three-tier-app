variable "docker_image" {
  description = "Docker image for ECS service (ECR URI)"
  type        = string
  default     = "" # set via terraform.tfvars or pass module output e.g. module.ecr.ecr_repo_uri
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "three-tier-demo"
}