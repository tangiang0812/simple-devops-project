packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

source "amazon-ebs" "gitlab_runner" {
  region        = "us-east-1"
  instance_type = "m7i-flex.large"
  ssh_username  = "ubuntu"

  source_ami_filter {
    filters = {
      name                = "GitLab CE 17.11.7*"
      architecture        = "x86_64"
      virtualization-type = "hvm"
    }

    owners      = ["782774275127"]
    most_recent = true
  }

  ami_name = "gitlab-runner-custom-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.gitlab_runner"]

  provisioner "shell" {
    script = "gitlab-runner-setup.sh"
  }
}