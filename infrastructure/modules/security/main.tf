
resource "aws_security_group" "gitlab_nlb_sec_group" {
  name        = "gitlab nlb sec group"
  description = "Allow HTTPs and SSH IPv4 In"
  vpc_id      = var.vpc_id
  tags = {
    Name = "gitlab_nlb_sec_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_nlb_ssh_from_any" {
  security_group_id = aws_security_group.gitlab_nlb_sec_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_nlb_https_from_any" {
  security_group_id = aws_security_group.gitlab_nlb_sec_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_gitlab_nlb_ssh_to_gitlab_rails" {
  security_group_id            = aws_security_group.gitlab_nlb_sec_group.id
  referenced_security_group_id = aws_security_group.gitlab_rails_sec_group.id
  # cidr_ipv4         = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "egress_gitlab_nlb_https_to_gitlab_alb" {
  security_group_id            = aws_security_group.gitlab_nlb_sec_group.id
  referenced_security_group_id = aws_security_group.gitlab_alb_sec_group.id
  # cidr_ipv4         = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_security_group" "gitlab_alb_sec_group" {
  name        = "gitlab alb sec group"
  description = "Allow HTTP IPv4 In"
  vpc_id      = var.vpc_id
  tags = {
    Name = "gitlab_alb_sec_group"
  }
}



resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_alb_https_from_gitlab_nlb" {
  security_group_id            = aws_security_group.gitlab_alb_sec_group.id
  referenced_security_group_id = aws_security_group.gitlab_nlb_sec_group.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_gitlab_alb_http_to_gitlab_rails" {
  security_group_id            = aws_security_group.gitlab_alb_sec_group.id
  referenced_security_group_id = aws_security_group.gitlab_rails_sec_group.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_security_group" "gitlab_rails_sec_group" {
  name        = "gitlab rails sec group"
  description = "Allow HTTP IPv4 In"
  vpc_id      = var.vpc_id
  tags = {
    Name = "gitlab_rails_sec_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_rails_ssh_from_gitlab_nlb" {
  security_group_id            = aws_security_group.gitlab_rails_sec_group.id
  referenced_security_group_id = aws_security_group.gitlab_nlb_sec_group.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "ingress_gitlab_rails_http_from_gitlab_alb" {
  security_group_id            = aws_security_group.gitlab_rails_sec_group.id
  referenced_security_group_id = aws_security_group.gitlab_alb_sec_group.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_security_group" "gitlab-rds-sec-group" {
  name        = "gitlab rds sec group"
  description = "Allow PostgreSQL IPv4 In"
  vpc_id      = var.vpc_id
  tags = {
    Name = "gitlab_rds_sec_group"
  }
}
