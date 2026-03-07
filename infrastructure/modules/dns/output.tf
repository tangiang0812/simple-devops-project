output "name_servers" {
  description = "The name servers for the Route 53 hosted zone."
  value       = aws_route53_zone.gitlab_zone.name_servers
}

output "zone_id" {
  description = "The ID of the Route 53 hosted zone."
  value       = aws_route53_zone.gitlab_zone.id
}
