###############################################################################
# ecs/main.tf  - COMPLETE file for ecs module (replace existing ecs/main.tf)
#
# Assumes these variables exist in ecs/variables.tf:
#   var.project_name, var.docker_image, var.app_port, var.rds_host,
#   var.rds_secret_name, var.aws_region
#
# This file creates:
#  - IAM execution role (required when using container secrets)
#  - CloudWatch log group
#  - ECS cluster, task definition (with execution_role_arn), and ECS service
###############################################################################

# -------------------------
# IAM: Task execution role
# -------------------------
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

# OPTIONAL: Task role (give to container if it must call AWS APIs at runtime)
# Uncomment and attach policies if your app needs AWS API calls.
#resource "aws_iam_role" "ecs_task_role" {
#  name = "${var.project_name}-ecs-task-role"
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [{
#      Effect = "Allow",
#      Principal = { Service = "ecs-tasks.amazonaws.com" },
#      Action = "sts:AssumeRole"
#    }]
#  })
#}
#
## attach additional policies to aws_iam_role.ecs_task_role as needed

# -------------------------
# CloudWatch Log Group
# -------------------------
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

# -------------------------
# Resolve existing secret
# -------------------------
data "aws_secretsmanager_secret" "rds" {
  # secret name provided by root module: var.rds_secret_name (e.g. "demo")
  name = var.rds_secret_name
}

# -------------------------
# ECS Cluster
# -------------------------
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster"
}

# -------------------------
# ECS Task Definition
# -------------------------
resource "aws_ecs_task_definition" "hello_task" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"

  # THIS IS REQUIRED WHEN USING container "secrets"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  # Optional: if your container needs AWS API permissions, uncomment task_role_arn
  # task_role_arn = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
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

    portMappings = [{
      containerPort = var.app_port
      hostPort      = var.app_port
    }]

    # Inject secrets from Secrets Manager into container env vars
  secrets = [
  {
    name      = "RDS_SECRET"
    valueFrom = "${data.aws_secretsmanager_secret.rds.arn}"
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
  }])
}

# -------------------------
# ECS Service
# -------------------------
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.hello_task.arn
  desired_count   = 1
  launch_type     = "EC2"
  # You can add deployment_controller or load_balancer config later if needed
}
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
