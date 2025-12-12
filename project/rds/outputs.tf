output "db_endpoint" {
  value = aws_db_instance.mysql.address
}

output "rds_secret_arn" {
  value       = aws_secretsmanager_secret.rds.arn
  description = "Secrets Manager ARN for RDS credentials"
}
