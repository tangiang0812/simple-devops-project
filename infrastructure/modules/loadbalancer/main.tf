resource "aws_lb" "gitlab_nlb" {
  name                       = "gitlab-nlb"
  internal                   = false
  load_balancer_type         = "network"
  subnets                    = var.public_subnets
  security_groups            = [var.nlb_sec_group_id]
  enable_deletion_protection = false
  # enable_cross_zone_load_balancing = true

  # access_logs {
  #   bucket  = var.health_logs_bucket_id
  #   enabled = true
  #   prefix  = "nlb"
  # }

  tags = {
    Name = "gitlab-nlb"
  }
}

resource "aws_lb_target_group" "gitlab_nlb_alb_target" {
  name        = "gitlab-nlb-alb-target"
  vpc_id      = var.vpc_id
  target_type = "alb"
  protocol    = "TCP"
  port        = 443
  # protocol_version = "TCP"

  health_check {
    protocol = "HTTPS"
    port     = 443
    path     = "/-/health"
    matcher  = "200-399"
    interval = 30
  }
}

resource "aws_lb_listener" "gitlab_nlb_alb_listener" {
  load_balancer_arn = aws_lb.gitlab_nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gitlab_nlb_alb_target.arn
  }
}

resource "aws_lb_target_group" "gitlab_nlb_ssh_target" {
  name        = "gitlab-nlb-ssh-target"
  vpc_id      = var.vpc_id
  target_type = "instance"
  protocol    = "TCP"
  port        = 22

  health_check {
    protocol = "TCP"
    port     = "22"
    interval = 30
  }
}

resource "aws_lb_listener" "gitlab_nlb_ssh_listener" {
  load_balancer_arn = aws_lb.gitlab_nlb.arn
  protocol          = "TCP"
  port              = "22"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gitlab_nlb_ssh_target.arn
  }
}


resource "aws_lb" "gitlab_alb" {
  name                       = "gitlab-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [var.alb_sec_group_id]
  subnets                    = var.private_subnets
  ip_address_type            = "ipv4"
  enable_deletion_protection = false

  access_logs {
    bucket  = var.health_logs_bucket_id
    enabled = true
    prefix  = "alb"
  }

  # dynamic "subnet_mapping" {
  #   for_each = var.private_subnets
  #   content {
  #     subnet_id = subnet_mapping.value
  #   }
  # }

  tags = {
    Name = " gitlab-alb"
  }
}

resource "aws_lb_target_group" "gitlab_alb_http_target" {
  name             = "gitlab-alb-http-target"
  vpc_id           = var.vpc_id
  target_type      = "instance"
  protocol         = "HTTP"
  port             = 80
  protocol_version = "HTTP1"

  health_check {
    protocol = "HTTP"
    path     = "/-/health"
    matcher  = "200-399"
    interval = 30
  }
}

resource "aws_lb_listener" "gitlab_alb_https_listener" {
  load_balancer_arn = aws_lb.gitlab_alb.arn
  protocol          = "HTTPS"
  port              = "443"
  certificate_arn   = var.alb_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gitlab_alb_http_target.arn
  }
  # depends_on = [aws_lb_target_group_attachment.gitlab_nlb_alb_attachment]
}

resource "aws_lb_target_group_attachment" "gitlab_nlb_alb_attachment" {
  target_group_arn = aws_lb_target_group.gitlab_nlb_alb_target.arn
  target_id        = aws_lb.gitlab_alb.arn
  port             = aws_lb_listener.gitlab_alb_https_listener.port
}

data "aws_lb_hosted_zone_id" "gitlab_alb" {
  load_balancer_type = "application"
}

data "aws_lb_hosted_zone_id" "gitlab_nlb" {
  load_balancer_type = "network"
}
