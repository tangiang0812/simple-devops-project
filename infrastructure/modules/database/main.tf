resource "aws_security_group" "database" {
  name        = "${var.name}-database-sg"
  description = "Security group for the RDS instance"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "database" {
  count                        = var.ingress_source_security_group_id != null ? 1 : 0
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = var.ingress_source_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_db_parameter_group" "database" {
  name   = "${var.name}-parameter-group"
  family = var.parameter_group_family
}

resource "aws_db_instance" "database" {
  identifier             = var.identifier
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.database.id]
  parameter_group_name   = aws_db_parameter_group.database.name
  skip_final_snapshot    = var.skip_final_snapshot
  #   availability_zone      = var.availability_zone
  multi_az = var.multi_az

  tags = merge({
    Name = "${var.name}-rds"
  }, var.tags)
}

