output "gitlab_alb_cert_arn" {
  description = "ARN of the ACM certificate for GitLab ALB."
  value       = aws_acm_certificate.gitlab_alb_cert.arn
}
