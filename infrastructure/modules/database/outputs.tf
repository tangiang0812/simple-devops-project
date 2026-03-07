output "loadbalancer_target_group_arn" {
  description = "ARN of the load balancer target group."
  value       = aws_lb_target_group.a4l.arn
}

output "loadbalancer_dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.a4l.dns_name
}
