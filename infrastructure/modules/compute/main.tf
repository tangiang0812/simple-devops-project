data "aws_ami" "gitlab_rails_ami" {
  most_recent = true

  owners = ["782774275127"]

  filter {
    name   = "name"
    values = ["GitLab CE 17.11.7*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "gitlab_rails_instance" {
  ami           = data.aws_ami.gitlab_rails_ami.id
  instance_type = "t3.micro"
  # instance_type = "c5.2xlarge"
  # iam_instance_profile        = var.iam_instance_profile_id
  # default user for gitlab-rails-instance is ubuntu, ssh
  subnet_id                   = var.private_subnets[0]
  key_name                    = aws_key_pair.bastion_key_pair.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.gitlab_rails_sec_group]
  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "gitlab-rails-instance"
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

# This is used without autoscaling group
resource "aws_instance" "bastion_host_a" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  iam_instance_profile        = var.bastion_instance_profile_id
  subnet_id                   = var.private_subnets[0]
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.bastion_host_sec_group]
  key_name                    = aws_key_pair.bastion_key_pair.key_name
  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "Bastion Host A"
  }
}

# This is used without autoscaling group
resource "aws_instance" "bastion_host_b" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  iam_instance_profile        = var.bastion_instance_profile_id
  subnet_id                   = var.private_subnets[1]
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.bastion_host_sec_group]
  key_name                    = aws_key_pair.bastion_key_pair.key_name
  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "Bastion Host B"
  }
}

resource "aws_instance" "bastion_host_c" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  iam_instance_profile        = var.bastion_instance_profile_id
  subnet_id                   = var.private_subnets[2]
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.bastion_host_sec_group]
  key_name                    = aws_key_pair.bastion_key_pair.key_name
  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "Bastion Host C"
  }
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name = "bastion-key-pair"
  # load public key from file
  public_key = file("${path.module}/id_rsa_terraform.pub")
}
