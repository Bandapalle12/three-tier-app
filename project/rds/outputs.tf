output "db_endpoint" {
  value = aws_db_instance.mysql.address
}


output "rds_secret_arn" {
  description = "ARN of existing Secrets Manager secret 'demo'"
  value       = data.aws_secretsmanager_secret.rds_existing.arn
}