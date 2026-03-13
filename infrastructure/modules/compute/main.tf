# data "aws_ami" "gitlab_rails_ami" {
#   most_recent = true

#   owners = ["782774275127"]

#   filter {
#     name   = "name"
#     values = ["GitLab CE 17.11.7*"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

data "aws_ami" "gitlab_rails_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["gitlab-rails-custom-*"]
  }
}

# resource "aws_instance" "gitlab_rails_instance" {
#   ami = data.aws_ami.gitlab_rails_ami.id
#   # instance_type = "t3.micro"
#   # default user for gitlab-rails-instance is ubuntu, ssh
#   instance_type               = "m7i-flex.large"
#   iam_instance_profile        = var.bastion_instance_profile_id
#   subnet_id                   = var.private_subnets[0]
#   key_name                    = aws_key_pair.bastion_key_pair.key_name
#   associate_public_ip_address = false
#   vpc_security_group_ids      = [var.gitlab_rails_sec_group]
#   credit_specification {
#     cpu_credits = "standard"
#   }

#   user_data = file("${path.module}/user_data_stage_5.sh")

#   tags = {
#     Name = "gitlab-rails-instance"
#   }
# }

resource "aws_autoscaling_group" "gitlab_rails_asg" {
  name                      = "gitlab-rails-autoscale-group"
  desired_capacity          = 3
  max_size                  = 5
  min_size                  = 1
  vpc_zone_identifier       = var.private_subnets
  target_group_arns         = [var.gitlab_alb_http_target_group_arn]
  health_check_grace_period = 300
  health_check_type         = "EC2"

  launch_template {
    id      = aws_launch_template.gitlab_rails_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "gitlab-rails-instance"
    propagate_at_launch = true
  }

}

resource "aws_launch_template" "gitlab_rails_launch_template" {
  name_prefix   = "gitlab-rails-launch-template"
  image_id      = data.aws_ami.gitlab_rails_ami.id
  instance_type = "m7i-flex.large"
  key_name      = aws_key_pair.bastion_key_pair.key_name

  iam_instance_profile {
    arn = var.gitlab_rails_instance_profile_arn
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      var.gitlab_rails_sec_group
    ]
  }

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = filebase64("${path.module}/user_data_stage_5.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "gitlab-rails-instance"
    }
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.10.20260202.2-kernel-6.1-x86_64"]

  }

  owners = ["137112412989"] # Canonical
}

# Bastion host ASG and launch template
resource "aws_autoscaling_group" "bastion_asg" {
  name                = "bastion-host-asg"
  desired_capacity    = 3
  max_size            = 3
  min_size            = 3
  vpc_zone_identifier = var.private_subnets
  target_group_arns   = [var.gitlab_nlb_ssh_target_group_arn]

  health_check_type = "EC2"

  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "bastion-host"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "bastion_launch_template" {
  name_prefix   = "bastion-launch-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.bastion_key_pair.key_name

  iam_instance_profile {
    arn = var.bastion_instance_profile_arn
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      var.bastion_host_sec_group
    ]
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Bastion Host"
    }
  }
}

# This is used without autoscaling group
# resource "aws_instance" "bastion_host_a" {
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = "t3.micro"
#   iam_instance_profile        = var.bastion_instance_profile_id
#   subnet_id                   = var.private_subnets[0]
#   associate_public_ip_address = false
#   vpc_security_group_ids      = [var.bastion_host_sec_group]
#   key_name                    = aws_key_pair.bastion_key_pair.key_name
#   credit_specification {
#     cpu_credits = "standard"
#   }

#   tags = {
#     Name = "Bastion Host A"
#   }
# }

# resource "aws_instance" "bastion_host_b" {
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = "t3.micro"
#   iam_instance_profile        = var.bastion_instance_profile_id
#   subnet_id                   = var.private_subnets[1]
#   associate_public_ip_address = false
#   vpc_security_group_ids      = [var.bastion_host_sec_group]
#   key_name                    = aws_key_pair.bastion_key_pair.key_name
#   credit_specification {
#     cpu_credits = "standard"
#   }

#   tags = {
#     Name = "Bastion Host B"
#   }
# }

# resource "aws_instance" "bastion_host_c" {
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = "t3.micro"
#   iam_instance_profile        = var.bastion_instance_profile_id
#   subnet_id                   = var.private_subnets[2]
#   associate_public_ip_address = false
#   vpc_security_group_ids      = [var.bastion_host_sec_group]
#   key_name                    = aws_key_pair.bastion_key_pair.key_name
#   credit_specification {
#     cpu_credits = "standard"
#   }

#   tags = {
#     Name = "Bastion Host C"
#   }
# }

resource "aws_key_pair" "bastion_key_pair" {
  key_name = "bastion-key-pair"
  # load public key from file
  public_key = file("${path.module}/id_rsa_terraform.pub")
}
