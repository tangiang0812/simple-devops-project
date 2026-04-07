

resource "aws_iam_role" "this" {
  name = "${var.name}-role"

  assume_role_policy = var.assume_role_policy
  path               = "/"

  tags = {
    Name = "${var.name}-role"
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = var.managed_policy_arns[count.index]
}

# resource "aws_iam_role_policy_attachment" "gitlab_rails_ssm_access" {
#   role       = aws_iam_role.gitlab_rails_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "gitlab_rails_ecr_access" {
#   role       = aws_iam_role.gitlab_rails_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
# }

# resource "aws_iam_role_policy_attachment" "gitlab_rails_asg_readonly" {
#   role       = aws_iam_role.gitlab_rails_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess"
# }

# resource "aws_iam_role_policy_attachment" "gitlab_rails_ec2_readonly" {
#   role       = aws_iam_role.gitlab_rails_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
# }

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0
  name  = "${var.name}-instance-profile"
  role  = aws_iam_role.this.name
}


