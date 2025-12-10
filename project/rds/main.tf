data "aws_rds_engine_version" "mysql" {
  engine = var.rds_engine
}

resource "aws_db_instance" "mysql" {
  identifier          = "three-tier-demo-db"
  engine              = "mysql"
  engine_version      = data.aws_rds_engine_version.mysql.version   
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = var.rds_username
  password            = var.rds_password
  skip_final_snapshot = true
}

