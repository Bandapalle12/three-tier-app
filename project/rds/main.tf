data "aws_rds_engine_version" "mysql" {
  engine = var.rds_engine
}




resource "aws_iam_role_policy_attachment" "ecs_instance_secrets" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_secretsmanager_secret" "rds" {
  name = "demo"
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = data.aws_secretsmanager_secret.rds_existing.id
}

# parse secret JSON into local map
locals {
  rds_secret = jsondecode(data.aws_secretsmanager_secret_version.rds_existing_version.secret_string)
  rds_secret_username = local.rds_secret.username
  rds_secret_password = local.rds_secret.password
}
# read an existing Secrets Manager secret named "demo"
data "aws_secretsmanager_secret" "rds_existing" {
name = "demo"
}


# Use the secret values when creating the DB
resource "aws_db_instance" "mysql" {
identifier = "${var.project_name}-db"
engine = var.rds_engine
engine_version = data.aws_rds_engine_version.mysql.version
instance_class = var.rds_instance_class
allocated_storage = var.rds_allocated_storage


# use values read from Secrets Manager
username = local.rds_secret_username
password = local.rds_secret_password


skip_final_snapshot = true
db_name = "testdb"


publicly_accessible = false
}