variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "three-tier-demo"
}

variable "public_subnets" {
  description = "List of public subnets new"
  type        = list(string)
  default     = [] # fill using data sources for default VPC
}

variable "vpc_id" {
  description = "VPC ID where EC2 instances will be launched"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for ECS cluster"
  type        = string
  default     = "t2.micro" # free-tier eligible
}

