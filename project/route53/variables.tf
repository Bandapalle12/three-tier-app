variable "domain_name" {
  description = "Hosted Zone domain name"
  type        = string
  default     = "example1.com"
}

variable "subdomain" {
  description = "Subdomain for ECS service"
  type        = string
  default     = "app"
}

variable "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  type        = string
}
