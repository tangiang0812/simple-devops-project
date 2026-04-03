resource "aws_security_group" "this" {
  name        = "${var.name}-sec-group"
  description = "Security group for Auto Scaling Group ${var.name}"
  vpc_id      = var.vpc_id
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-autoscale-group"
  desired_capacity          = 1
  max_size                  = 3
  min_size                  = 1
  vpc_zone_identifier       = var.subnets
  target_group_arns         = [var.lb_target_group_arn]
  health_check_grace_period = 300
  health_check_type         = "EC2"

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-instance"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-launch-template"
  image_id      = var.ami_id
  instance_type = "m7i-flex.large"
  key_name      = aws_key_pair.this.key_name

  iam_instance_profile {
    arn = var.instance_profile_arn
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      aws_security_group.this.id
    ]
  }

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = var.user_data

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = "${var.name}-instance"
      },
      var.tags
    )
  }
}

resource "aws_key_pair" "this" {
  key_name = "${var.name}-key-pair"
  # load public key from file
  public_key = file("${path.module}/id_rsa_terraform.pub")

  tags = merge(
    {
      Name = "${var.name}-key-pair"
    },
    var.tags
  )
}
