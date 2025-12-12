
provider "aws" {
  region = var.aws_region
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  vpc_id         = data.aws_vpc.default.id
  public_subnets = data.aws_subnets.default_public.ids
}

module "ec2" {
  source = "./ec2"

  instance_type  = var.instance_type
  project_name   = var.project_name
  vpc_id         = local.vpc_id        # <-- required by EC2 module
  public_subnets = local.public_subnets
}

module "ecs" {
  source = "./ecs"

  project_name    = var.project_name
  docker_image    = var.docker_image
  app_port        = var.app_port
  aws_region      = var.aws_region

  rds_username = var.rds_username
  rds_password = var.rds_password
  rds_host = module.rds.db_endpoint
  rds_secret_name = "demo"

}

module "rds" {
  source = "./rds"

  project_name          = var.project_name
  rds_engine            = var.rds_engine
  rds_instance_class    = var.rds_instance_class
  rds_allocated_storage = var.rds_allocated_storage
  rds_username          = var.rds_username
  rds_password          = var.rds_password

}


module "route53" {
  source = "./route53"

  domain_name   = var.domain_name
  subdomain     = var.subdomain

  # Pass the public IP from EC2 module output
  ec2_public_ip = module.ec2.public_ip
}

