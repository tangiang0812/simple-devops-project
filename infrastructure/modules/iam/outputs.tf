output "instance_profile_id" {
  value = try(aws_iam_instance_profile.this[0].id, "")
}

output "instance_profile_arn" {
  value = try(aws_iam_instance_profile.this[0].arn, "")
}

output "role_arn" {
  value = aws_iam_role.this.arn
}
