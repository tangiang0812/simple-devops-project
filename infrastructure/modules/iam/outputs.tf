output "instance_profile_id" {
  value = aws_iam_instance_profile.this[0].id
}

output "instance_profile_arn" {
  value = aws_iam_instance_profile.this[0].arn
}
