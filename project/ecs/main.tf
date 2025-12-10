resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecs_task_definition" "hello_task" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name             = "hello-world"
    image            = var.docker_image
    essential        = true
    memory           = 256
    memoryReservation = 128

    environment = [
      {
        name  = "RDS_HOST"
        value = var.rds_host
      },
      {
        name  = "username"
        value = var.rds_username
      },
      {
        name  = "password"
        value = var.rds_password
      }
    ]

    portMappings = [{
      containerPort = var.app_port
      hostPort      = var.app_port
    }]
  }])
}


resource "aws_ecs_service" "ecs_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.hello_task.arn
  desired_count   = 1
  launch_type     = "EC2"
}


