output "bastion_instance_profile_id" {
  value = aws_iam_instance_profile.bastion_instance_profile.id
}

output "bastion_instance_profile_arn" {
  value = aws_iam_instance_profile.bastion_instance_profile.arn
}

output "gitlab_rails_instance_profile_id" {
  value = aws_iam_instance_profile.gitlab_rails_instance_profile.id
}

output "gitlab_rails_instance_profile_arn" {
  value = aws_iam_instance_profile.gitlab_rails_instance_profile.arn
}
