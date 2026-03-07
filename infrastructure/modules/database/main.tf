resource "aws_db_parameter_group" "gitlab_rds" {
  name   = "gitlab-rds"
  family = "postgres14"
}


resource "aws_db_instance" "gitlab_db_ha" {
  identifier             = "gitlab-db-ha"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14"
  db_name                = "gitlabhq_production"
  username               = "a4lgitlabuser"
  password               = "4n1m4l54L1f3"
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  parameter_group_name   = aws_db_parameter_group.gitlab_rds.name
  skip_final_snapshot    = true
  #   availability_zone      = var.availability_zone
  multi_az = true
}

