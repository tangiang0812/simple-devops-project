output "lb_arn" {
  description = "The ARN of the load balancer."
  value       = aws_lb.this.arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.this.dns_name
}

output "lb_security_group_id" {
  description = "The security group ID of the load balancer."
  value       = aws_security_group.this.id
}

output "lb_id" {
  description = "The ID of the load balancer."
  value       = aws_lb.this.id
}

output "lb_hosted_zone_id" {
  description = "The hosted zone ID of the load balancer."
  value       = data.aws_lb_hosted_zone_id.this.id
}

output "target_group_arns" {
  description = "A map of target group ARNs, keyed by target group name."
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}
