output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ecs_instance[0].id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.ecs_instance[0].public_ip
}

