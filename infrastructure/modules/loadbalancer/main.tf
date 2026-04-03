locals {
  lb_name                  = "${var.name}-${var.lb_type}"
  target_group_attachments = { for k, v in var.target_groups : k => v if v.target_id != null }
}

resource "aws_security_group" "this" {
  name        = "${local.lb_name}-sg"
  description = "Security group for ${local.lb_name} load balancer"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "${local.lb_name}-sg"
  }, var.tags)
}

resource "aws_lb" "this" {
  name                       = local.lb_name
  internal                   = var.internal
  load_balancer_type         = var.lb_type
  ip_address_type            = var.ip_address_type
  subnets                    = var.subnet_ids
  security_groups            = [aws_security_group.this.id]
  enable_deletion_protection = false
  # enable_cross_zone_load_balancing = true

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []
    content {
      bucket  = var.access_logs.bucket
      enabled = true
      prefix  = try(access_logs.value.prefix, "${local.lb_name}-logs")
    }
  }

  tags = merge({
    Name = local.lb_name
  }, var.tags)
}

resource "aws_lb_target_group" "this" {
  for_each    = var.target_groups != null ? var.target_groups : {}
  name        = each.value.name
  vpc_id      = var.vpc_id
  target_type = each.value.target_type
  protocol    = each.value.protocol
  port        = each.value.port
  dynamic "health_check" {
    for_each = each.value.health_check != null ? [each.value.health_check] : []
    content {
      protocol            = health_check.value.protocol
      port                = try(health_check.value.port, null)
      path                = try(health_check.value.path, null)
      matcher             = try(health_check.value.matcher, "200-399")
      interval            = try(health_check.value.interval, null)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
      enabled             = try(health_check.value.enabled, null)
    }
  }

  tags = merge({
    Name = "${local.lb_name}-${each.value.name}-tg"
  }, var.tags)
}

resource "aws_lb_listener" "this" {

  for_each          = var.listeners != null ? var.listeners : {}
  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  certificate_arn   = try(each.value.certificate_arn, null)
  ssl_policy        = try(each.value.ssl_policy, null)

  default_action {
    type             = each.value.default_action.type
    target_group_arn = aws_lb_target_group.this[each.value.default_action.target_group_key].arn
  }

  tags = merge({
    Name = "${local.lb_name}-listener-${each.value.port}"
  }, var.tags)
}

resource "aws_lb_target_group_attachment" "this" {
  for_each         = var.target_groups != null ? { for k, v in var.target_groups : k => v if v.create_attachment == true } : {}
  target_group_arn = aws_lb_target_group.this[each.key].arn
  target_id        = each.value.target_id
  port             = each.value.port
}

data "aws_lb_hosted_zone_id" "this" {
  load_balancer_type = var.lb_type
}
