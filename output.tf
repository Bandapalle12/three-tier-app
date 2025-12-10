output "hello_world_role_arn" {
  description = "ARN of the test IAM role"
  value       = aws_iam_role.hello_world_role.arn
}
