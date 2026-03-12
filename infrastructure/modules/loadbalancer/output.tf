output "alb_target_group_arn" {
  description = "ARN of the load balancer target group."
  value       = aws_lb_target_group.gitlab_alb_http_target.arn
}

output "alb_dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.gitlab_alb.dns_name
}

output "alb_hosted_zone_id" {
  description = "Hosted zone ID of the load balancer."
  value       = data.aws_lb_hosted_zone_id.gitlab_alb.id
}

output "nlb_target_group_arn" {
  description = "ARN of the load balancer target group."
  value       = aws_lb_target_group.gitlab_nlb_alb_target.arn
}

output "nlb_dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.gitlab_nlb.dns_name
}

output "nlb_hosted_zone_id" {
  description = "Hosted zone ID of the load balancer."
  value       = data.aws_lb_hosted_zone_id.gitlab_nlb.id
}

# output "alb_private_ip_addresses" {
#   description = "Private IP addresses of the load balancer."
#   value       = aws_lb.gitlab_alb.subnet_mapping[*].private_ip_address
# }
