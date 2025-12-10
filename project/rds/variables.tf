variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "three-tier-demo"
}

variable "rds_engine" {
  description = "Database Engine"
  type        = string
  default     = "mysql"
}

variable "rds_instance_class" {
  description = "RDS Instance Class (Free Tier eligible)"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage"
  type        = number
  default     = 20
}

variable "rds_username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "rds_password" {
  description = "Master password"
  type        = string
  sensitive   = true
  default     = "Test12345!"
}


