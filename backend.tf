terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "terraform-state-backend-new"   # 👈 your existing bucket name
    key            = "demo/terraform.tfstate"  # 👈 path inside bucket
    region         = "us-east-1"                  # 👈 bucket region
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
## 3. `provider.tf` – AWS provider

provider "aws" {
  region = var.aws_region
}
