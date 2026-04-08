#!/bin/bash
set -xe

sudo rm -f /usr/share/keyrings/gitlab_gitlab-ce-archive-keyring.gpg

curl https://packages.gitlab.com/gpg.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/gitlab_gitlab-ce-archive-keyring.gpg

sudo apt-get update
# sudo apt upgrade -y

sudo apt-get install -y unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install