data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "ecs_instance" {
  count         = 1
  ami           = data.aws_ami.ecs.id
  instance_type = var.instance_type
  subnet_id     = var.public_subnets[0]
  key_name      = var.key_name
  
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${var.project_name}-cluster >> /etc/ecs/ecs.config
              EOF

  tags = {
    Name = "${var.project_name}-ecs-instance"
  }

}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.project_name}-ecs-instance-role18"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_ecr_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.project_name}-ecs-instance-profile18"
  role = aws_iam_role.ecs_instance_role.name
}

# allow ECS host to write logs
resource "aws_iam_role_policy" "ecs_instance_logs_policy" {
  name = "${var.project_name}-ecs-logs-policy"
  role = aws_iam_role.ecs_instance_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"   # narrow this if you want (see note)
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_instance_secrets" {
role = aws_iam_role.ecs_instance_role.name
policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
