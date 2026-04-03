output "security_group_id" {
  description = "The security group ID of the EC2 instance."
  value       = aws_security_group.this.id
}
