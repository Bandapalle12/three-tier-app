
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow ECS task to read the RDS secret
resource "aws_iam_role_policy" "ecs_task_exec_secrets" {
  name = "${var.project_name}-ecs-task-exec-secrets"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = data.aws_secretsmanager_secret.rds.arn
      }
    ]
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}


# Secrets Manager reference
data "aws_secretsmanager_secret" "rds" {
  name = var.rds_secret_name
}


# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "hello_task" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name              = "hello-world"
      image             = var.docker_image
      essential         = true
      memory            = 256
      memoryReservation = 128

      environment = [
        {
          name  = "RDS_HOST"
          value = var.rds_host
        }
      ]

      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]

      secrets = [
        {
          name      = "RDS_SECRET"
          valueFrom = data.aws_secretsmanager_secret.rds.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = var.project_name
        }
      }
    }
  ])
}


# ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.hello_task.arn
  desired_count   = 1
  launch_type     = "EC2"
}
