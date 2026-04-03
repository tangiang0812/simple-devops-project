data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/../network/terraform.tfstate"
  }
}

data "terraform_remote_state" "stateful" {
  backend = "local"
  config = {
    path = "${path.module}/../stateful/terraform.tfstate"
  }
}

data "aws_ami" "gitlab_rails_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["gitlab-rails-custom-*"]
  }

  owners = ["self"]
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.10.20260202.2-kernel-6.1-x86_64"]

  }

  owners = ["137112412989"] # Canonical
}
